'use strict';

const path = require('node:path');

/**
 * electron-builder afterPack hook.
 *
 * `signAndEditExecutable` is disabled so the build never needs the winCodeSign
 * download (its macOS symlinks cannot be extracted without admin rights on
 * Windows). That also means electron-builder does not touch the app executable,
 * so we embed the icon and version metadata here with rcedit.
 */
exports.default = async function afterPack(context) {
  if (context.electronPlatformName !== 'win32') {
    return;
  }

  const { rcedit } = await import('rcedit');
  const projectDir = context.packager.projectDir;
  const exePath = path.join(context.appOutDir, 'TempSticky.exe');

  await rcedit(exePath, {
    icon: path.join(projectDir, 'assets', 'tempsticky.ico'),
    'file-version': context.packager.appInfo.version + '.0',
    'product-version': context.packager.appInfo.version,
    'version-string': {
      FileDescription: 'TempSticky',
      ProductName: 'TempSticky',
      CompanyName: 'knight-dev01',
      LegalCopyright: 'MIT License',
      OriginalFilename: 'TempSticky.exe'
    }
  });

  console.log('  - embedded TempSticky icon and version information');
};
