; ============================================================
;  SistemBakim v5.0 - Inno Setup Installer Script
;  Kurumsal standart Windows kurulum sihirbazi
;
;  Derleme : Inno Setup 6.x ile "SistemBakim_Setup.iss" ac > Compile
;  Cikti   : SistemBakim_Setup.exe (~1 MB)
; ============================================================

#define MyAppName "SistemBakim"
#define MyAppVersion "5.0"
#define MyAppPublisher "Erdi"
#define MyAppURL "https://github.com/erdiyim/SistemBakim"
#define MyAppExeName "SistemBakim.exe"
#define MyAppCLIName "SistemBakim_CLI.exe"

[Setup]
; Temel bilgiler
AppId={{A7E3F2B1-9C4D-4E5F-8B6A-1D2E3F4A5B6C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; Cikti ayarlari
OutputDir=..\installer\output
OutputBaseFilename=SistemBakim_v{#MyAppVersion}_Setup
SetupIconFile=..\src\sistem.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName} v{#MyAppVersion}

; Yetki ve mimari
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Sihirbaz gorunumu
WizardStyle=modern
WizardSizePercent=110,110
WizardImageFile=compiler:WizModernImage-IS.bmp
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp

; Sikistirma
Compression=lzma2/ultra64
SolidCompression=yes
LZMANumBlockThreads=4

; Diger
AllowNoIcons=yes
ShowLanguageDialog=auto
MinVersion=10.0
CloseApplications=force
RestartApplications=no
DisableWelcomePage=no

; Dijital imza notu
; SignTool kullanarak imzalamak SmartScreen uyarilarini ortadan kaldirir:
; SignTool=signtool sign /f "sertifika.pfx" /p "sifre" /tr http://timestamp.digicert.com /td sha256 $f

[Languages]
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
turkish.LaunchApp=Uygulamayi calistir
turkish.CreateDesktopIcon=Masaustune kisayol olustur
turkish.DeleteUserData=Kullanici verilerini de sil (ayarlar, loglar, yedekler)
english.LaunchApp=Launch application
english.CreateDesktopIcon=Create a desktop shortcut
english.DeleteUserData=Also delete user data (settings, logs, backups)

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checked

[Files]
; Ana uygulama dosyalari
Source: "..\bin\SistemBakim.exe";     DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\SistemBakim_CLI.exe";  DestDir: "{app}"; Flags: ignoreversion
Source: "..\src\sistem.ico";           DestDir: "{app}"; Flags: ignoreversion

; Lisans ve bilgi dosyalari (varsa)
; Source: "..\LICENSE";                DestDir: "{app}"; Flags: ignoreversion; DestName: "LICENSE.txt"
; Source: "..\README.md";              DestDir: "{app}"; Flags: ignoreversion isreadme

[Icons]
; Baslat Menusu
Name: "{group}\{#MyAppName}";                      Filename: "{app}\{#MyAppExeName}";  IconFilename: "{app}\sistem.ico"; Comment: "Sistem bakim ve optimizasyon araci"
Name: "{group}\{#MyAppName} (Konsol)";              Filename: "{app}\{#MyAppCLIName}";  IconFilename: "{app}\sistem.ico"; Comment: "Komut satiri arayuzu"
Name: "{group}\{#MyAppName} Kaldir";                Filename: "{uninstallexe}";          IconFilename: "{app}\sistem.ico"

; Masaustu kisayolu (kullanici secerse)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\sistem.ico"; Tasks: desktopicon; Comment: "Sistem bakim ve optimizasyon araci"

[Registry]
; Uygulama kayit bilgileri (Program Ekle/Kaldir entegrasyonu otomatik, burasi ek metadata)
Root: HKLM; Subkey: "SOFTWARE\{#MyAppName}"; ValueType: string; ValueName: "InstallDir";  ValueData: "{app}";              Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\{#MyAppName}"; ValueType: string; ValueName: "Version";     ValueData: "{#MyAppVersion}";    Flags: uninsdeletekey

[Run]
; Kurulum sonrasi "Uygulamayi Calistir" secenegi
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchApp}"; Flags: nowait postinstall skipifsilent shellexec runascurrentuser

[UninstallRun]
; Kaldirma oncesi temizlik
Filename: "{cmd}"; Parameters: "/C taskkill /F /IM SistemBakim.exe /T 2>nul & taskkill /F /IM SistemBakim_CLI.exe /T 2>nul"; Flags: runhidden waituntilterminated

[UninstallDelete]
; Kurulum dizinindeki tum dosyalar
Type: filesandordirs; Name: "{app}"

[Code]
// ============================================================
//  Pascal Script — Kaldirim Sonrasi Kullanici Veri Temizligi
// ============================================================

var
  DeleteUserDataCheckbox: TNewCheckBox;

// Kaldirma onay sayfasina "Kullanici verilerini de sil" kutucugu ekle
procedure InitializeUninstallProgressForm();
begin
  DeleteUserDataCheckbox := TNewCheckBox.Create(UninstallProgressForm);
  DeleteUserDataCheckbox.Parent := UninstallProgressForm;
  DeleteUserDataCheckbox.Left := ScaleX(20);
  DeleteUserDataCheckbox.Top := UninstallProgressForm.StatusLabel.Top + UninstallProgressForm.StatusLabel.Height + ScaleY(24);
  DeleteUserDataCheckbox.Width := ScaleX(400);
  DeleteUserDataCheckbox.Height := ScaleY(22);
  DeleteUserDataCheckbox.Caption := CustomMessage('DeleteUserData');
  DeleteUserDataCheckbox.Checked := False;
  DeleteUserDataCheckbox.Font.Style := [fsBold];
end;

// Kaldirma islemi tamamlaninca kullanici verileri temizle (secildiyse)
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  AppDataDir: String;
  DesktopReports: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Kullanici verilerini sil (kutucuk isaretliyse)
    if DeleteUserDataCheckbox.Checked then
    begin
      AppDataDir := ExpandConstant('{userappdata}\SistemBakim');
      if DirExists(AppDataDir) then
      begin
        DelTree(AppDataDir, True, True, True);
      end;

      // Masaustundeki BakimRaporlari klasoru
      DesktopReports := ExpandConstant('{userdesktop}\..\BakimRaporlari');
      // Guvenligi icin sadece uyari verelim, elle silme tercihi birakiyoruz
      // DelTree(DesktopReports, True, True, True);
    end;

    // Registry anahtarlarini temizle
    RegDeleteKeyIncludingSubkeys(HKLM, 'SOFTWARE\SistemBakim');
  end;
end;

// Kurulum oncesi: eski surum calisiyorsa kapat
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  // Calisan instance'i kapat
  Exec('taskkill', '/F /IM SistemBakim.exe /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill', '/F /IM SistemBakim_CLI.exe /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := True;
end;

// 32-bit sistemde kurulumu engelle
function InitializeWizard(): Boolean;
begin
  Result := True;
  if not IsWin64 then
  begin
    MsgBox('SistemBakim sadece 64-bit Windows 10/11 uzerinde calisir.', mbCriticalError, MB_OK);
    Result := False;
  end;
end;
