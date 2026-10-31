using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Threading;
using LibreHardwareMonitor.Hardware;

internal static class TempSensor
{
    private static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

    private static string JsonEscape(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        var sb = new StringBuilder(s.Length + 8);
        foreach (char c in s)
        {
            switch (c)
            {
                case '"': sb.Append("\\\""); break;
                case '\\': sb.Append("\\\\"); break;
                case '\n': sb.Append("\\n"); break;
                case '\r': sb.Append("\\r"); break;
                case '\t': sb.Append("\\t"); break;
                default:
                    if (c < ' ') sb.Append("\\u").Append(((int)c).ToString("x4", Inv));
                    else sb.Append(c);
                    break;
            }
        }
        return sb.ToString();
    }

    private static void WriteAtomic(string path, string content)
    {
        try
        {
            string dir = Path.GetDirectoryName(path);
            if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir)) Directory.CreateDirectory(dir);
            string tmp = path + ".tmp";
            File.WriteAllText(tmp, content, new UTF8Encoding(false));
            if (File.Exists(path)) File.Delete(path);
            File.Move(tmp, path);
        }
        catch { }
    }

    private static int Main(string[] args)
    {
        string outPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "TempSticky", "sensor.json");
        int interval = 2000;
        bool dump = false;
        bool sawPath = false;

        foreach (string a in args)
        {
            if (a == "--dump") { dump = true; continue; }
            if (a.StartsWith("--")) continue;
            if (!sawPath) { outPath = a; sawPath = true; continue; }
            int parsed;
            if (int.TryParse(a, out parsed)) interval = parsed;
        }
        if (interval < 500) interval = 500;

        Computer computer = null;
        string openError = null;
        try
        {
            computer = new Computer
            {
                IsCpuEnabled = true,
                IsGpuEnabled = true,
                IsMotherboardEnabled = true,
                IsControllerEnabled = true,
                IsStorageEnabled = false,
                IsMemoryEnabled = false,
                IsNetworkEnabled = false,
                IsBatteryEnabled = false,
                IsPsuEnabled = false
            };
            computer.Open();
        }
        catch (Exception ex)
        {
            openError = ex.GetType().Name + ": " + ex.Message;
        }

        if (dump)
        {
            var sb = new StringBuilder(4096);
            sb.Append("{\"admin\":").Append(IsAdmin() ? "true" : "false");
            sb.Append(",\"error\":").Append(openError != null ? "\"" + JsonEscape(openError) + "\"" : "null");
            sb.Append(",\"hardware\":[");
            if (computer != null)
            {
                bool firstHw = true;
                foreach (IHardware hw in computer.Hardware)
                {
                    try { hw.Update(); } catch { }
                    if (!firstHw) sb.Append(',');
                    firstHw = false;
                    sb.Append("{\"name\":\"").Append(JsonEscape(hw.Name)).Append("\",\"type\":\"")
                      .Append(hw.HardwareType).Append("\",\"sensors\":[");
                    bool firstS = true;
                    foreach (ISensor s in hw.Sensors)
                    {
                        if (!firstS) sb.Append(',');
                        firstS = false;
                        sb.Append("{\"n\":\"").Append(JsonEscape(s.Name)).Append("\",\"t\":\"").Append(s.SensorType).Append("\",\"v\":");
                        sb.Append(s.Value.HasValue ? s.Value.Value.ToString("0.##", Inv) : "null").Append('}');
                    }
                    sb.Append("]}");
                }
            }
            sb.Append("]}");
            WriteAtomic(outPath, sb.ToString());
            return 0;
        }

        while (true)
        {
            double? cpu = null, gpu = null, load = null, hottest = null;
            string cpuName = null;
            var temps = new List<string>();
            string loopError = openError;

            if (computer != null)
            {
                try
                {
                    foreach (IHardware hw in computer.Hardware)
                    {
                        try { hw.Update(); } catch { }
                        foreach (IHardware sub in hw.SubHardware)
                        {
                            try { sub.Update(); } catch { }
                        }

                        foreach (ISensor s in hw.Sensors)
                        {
                            if (s.Value == null) continue;
                            double v = s.Value.Value;

                            if (s.SensorType == SensorType.Temperature)
                            {
                                string n = s.Name ?? "";
                                string hwName = hw.Name ?? "";
                                if (temps.Count < 24)
                                {
                                    temps.Add("{\"hw\":\"" + JsonEscape(hwName) + "\",\"n\":\"" + JsonEscape(n) +
                                              "\",\"v\":" + v.ToString("0.0", Inv) + "}");
                                }

                                if (hw.HardwareType == HardwareType.Cpu)
                                {
                                    if (n == "CPU Package" || n == "Core Max" || n == "Core Average" ||
                                        n.IndexOf("Tctl", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                        n.IndexOf("Tdie", StringComparison.OrdinalIgnoreCase) >= 0)
                                    {
                                        if (cpu == null || n == "CPU Package") { cpu = v; cpuName = n; }
                                    }
                                    if (hottest == null || v > hottest.Value) hottest = v;
                                }
                                else if (hw.HardwareType == HardwareType.GpuIntel ||
                                         hw.HardwareType == HardwareType.GpuNvidia ||
                                         hw.HardwareType == HardwareType.GpuAmd)
                                {
                                    if (n == "GPU Core" || n == "GPU Package" || n == "GPU Hot Spot")
                                    {
                                        if (gpu == null || n == "GPU Core") gpu = v;
                                    }
                                }
                            }
                            else if (s.SensorType == SensorType.Load && s.Name == "CPU Total")
                            {
                                load = v;
                            }
                        }
                    }

                    if (cpu == null) { cpu = hottest; if (cpu != null) cpuName = "hottest core"; }
                }
                catch (Exception ex)
                {
                    loopError = ex.GetType().Name + ": " + ex.Message;
                }
            }

            long ts = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            var sb = new StringBuilder(512);
            sb.Append('{');
            sb.Append("\"ok\":").Append(cpu != null ? "true" : "false");
            sb.Append(",\"ts\":").Append(ts.ToString(Inv));
            sb.Append(",\"cpu\":").Append(cpu.HasValue ? cpu.Value.ToString("0.0", Inv) : "null");
            sb.Append(",\"cpuName\":").Append(cpuName != null ? "\"" + JsonEscape(cpuName) + "\"" : "null");
            sb.Append(",\"gpu\":").Append(gpu.HasValue ? gpu.Value.ToString("0.0", Inv) : "null");
            sb.Append(",\"load\":").Append(load.HasValue ? load.Value.ToString("0", Inv) : "null");
            sb.Append(",\"source\":\"LibreHardwareMonitor\"");
            sb.Append(",\"admin\":").Append(IsAdmin() ? "true" : "false");
            sb.Append(",\"error\":").Append(loopError != null ? "\"" + JsonEscape(loopError) + "\"" : "null");
            sb.Append(",\"temps\":[").Append(string.Join(",", temps.ToArray())).Append("]}");

            WriteAtomic(outPath, sb.ToString());
            Thread.Sleep(interval);
        }
    }

    private static bool IsAdmin()
    {
        try
        {
            var id = System.Security.Principal.WindowsIdentity.GetCurrent();
            var p = new System.Security.Principal.WindowsPrincipal(id);
            return p.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
        }
        catch { return false; }
    }
}
