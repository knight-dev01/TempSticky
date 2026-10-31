'use strict';

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('tempsticky', {
  getState: () => ipcRenderer.invoke('app:get-state'),
  windowInfo: () => ipcRenderer.invoke('app:window-info'),
  action: (name, payload) => ipcRenderer.send('app:action', name, payload),
  onState: (cb) => {
    const handler = (_e, state) => cb(state);
    ipcRenderer.on('app:state', handler);
    return () => ipcRenderer.removeListener('app:state', handler);
  },
  onSettings: (cb) => {
    const handler = (_e, settings) => cb(settings);
    ipcRenderer.on('app:settings', handler);
    return () => ipcRenderer.removeListener('app:settings', handler);
  }
});
