; ============================================================
;  SistemBakim v5.0.0 - Inno Setup Installer Script
;  Profesyonel Windows kurulum sihirbazi
;
;  Derleme : ISCC.exe SistemBakim_Setup.iss
;  Cikti   : installer\output\SistemBakim_v5.0.0_Setup.exe
; ============================================================

#define MyAppName      "SistemBakim"
#define MyAppVersion   "5.0.0"
#define MyAppPublisher "Erdi Yilmaz"
#define MyAppURL       "https://github.com/erdiyim/SistemBakim"
#define MyAppExeName   "SistemBakim.exe"
#define MyAppCLIName   "SistemBakim_CLI.exe"

; ============================================================
;  [Setup] — Kurulum motor ayarlari
; ============================================================
[Setup]
AppId={{A7E3F2B1-9C4D-4E5F-8B6A-1D2E3F4A5B6C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
AppContact={#MyAppURL}/issues

; Kurulum dizini: C:\Program Files\SistemBakim
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; Cikti dosyasi
OutputDir=..\installer\output
OutputBaseFilename=SistemBakim_v{#MyAppVersion}_Setup
SetupIconFile=..\src\sistem.ico
UninstallDisplayIcon={app}\sistem.ico
UninstallDisplayName={#MyAppName} v{#MyAppVersion}

; Yetki: Admin gerekli (registry ve servis islemleri icin)
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Modern sihirbaz gorunumu
WizardStyle=modern
WizardSizePercent=110,110
; WizardImageFile ve SmallImageFile: varsayilan kullaniliyor

; LZMA2 ultra sikistirma — minimum cikti boyutu
Compression=lzma2/ultra64
SolidCompression=yes
LZMANumBlockThreads=4

; Genel davranis
AllowNoIcons=yes
ShowLanguageDialog=auto
MinVersion=10.0
CloseApplications=force
RestartApplications=no
DisableWelcomePage=no
UsePreviousAppDir=yes
UsePreviousGroup=yes
UsePreviousSetupType=yes

; Surum bilgisi (Explorer > Ozellikler'de gorunur)
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=Windows Sistem Bakim ve Optimizasyon Araci
VersionInfoCopyright=2025 {#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

; ============================================================
;  [Languages] — Dil destegi
; ============================================================
[Languages]
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

; ============================================================
;  [CustomMessages] — Ozel metinler
; ============================================================
[CustomMessages]
turkish.LaunchApp=SistemBakim'i simdi calistir
turkish.CreateDesktopIcon=Masaustune kisayol olustur
turkish.AddToPath=CLI aracini sistem PATH'e ekle (komut satirindan erisim)
turkish.DeleteUserData=Kullanici verilerini de sil (ayarlar, loglar, yedekler)
english.LaunchApp=Launch SistemBakim now
english.CreateDesktopIcon=Create a desktop shortcut
english.AddToPath=Add CLI tool to system PATH (command-line access)
english.DeleteUserData=Also delete user data (settings, logs, backups)

; ============================================================
;  [Tasks] — Kullanici secenekleri
; ============================================================
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "addtopath";   Description: "{cm:AddToPath}"; Flags: unchecked

; ============================================================
;  [Files] — Kuruluma dahil dosyalar
; ============================================================
[Files]
; Ana uygulama (GUI)
Source: "..\bin\{#MyAppExeName}";     DestDir: "{app}"; Flags: ignoreversion
; Komut satiri arayuzu (CLI)
Source: "..\bin\{#MyAppCLIName}";     DestDir: "{app}"; Flags: ignoreversion
; Uygulama ikonu
Source: "..\src\sistem.ico";          DestDir: "{app}"; Flags: ignoreversion
; Lisans ve dokumasyon
Source: "..\LICENSE";                 DestDir: "{app}"; DestName: "LICENSE.txt"; Flags: ignoreversion
Source: "..\README.md";               DestDir: "{app}"; Flags: ignoreversion

; ============================================================
;  [Icons] — Kisayollar (Baslat Menusu + Masaustu)
; ============================================================
[Icons]
; Baslat Menusu grubu
Name: "{group}\{#MyAppName}";              Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\sistem.ico"; Comment: "Sistem bakim ve optimizasyon araci"
Name: "{group}\{#MyAppName} (Konsol)";     Filename: "{app}\{#MyAppCLIName}"; IconFilename: "{app}\sistem.ico"; Comment: "Komut satiri arayuzu"
Name: "{group}\{#MyAppName} Websitesi";    Filename: "{#MyAppURL}"
Name: "{group}\{#MyAppName} Kaldir";       Filename: "{uninstallexe}";        IconFilename: "{app}\sistem.ico"

; Masaustu kisayolu (kullanici isterse — varsayilan: isaretli)
Name: "{autodesktop}\{#MyAppName}";        Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\sistem.ico"; Tasks: desktopicon; Comment: "Sistem bakim ve optimizasyon araci"

; ============================================================
;  [Registry] — Uygulama kayit bilgileri
; ============================================================
[Registry]
; Uygulama metadata
Root: HKLM; Subkey: "SOFTWARE\{#MyAppName}"; ValueType: string; ValueName: "InstallDir";    ValueData: "{app}";            Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\{#MyAppName}"; ValueType: string; ValueName: "Version";       ValueData: "{#MyAppVersion}";  Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\{#MyAppName}"; ValueType: string; ValueName: "Publisher";     ValueData: "{#MyAppPublisher}"; Flags: uninsdeletekey

; PATH'e ekle (sadece kullanici sectiyse)
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Tasks: addtopath; Check: NeedsAddPath('{app}')

; ============================================================
;  [Run] — Kurulum sonrasi islemler
; ============================================================
[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchApp}"; Flags: nowait postinstall skipifsilent shellexec runascurrentuser

; ============================================================
;  [UninstallRun] — Kaldirma oncesi temizlik
; ============================================================
[UninstallRun]
Filename: "{cmd}"; Parameters: "/C taskkill /F /IM {#MyAppExeName} /T 2>nul & taskkill /F /IM {#MyAppCLIName} /T 2>nul"; Flags: runhidden waituntilterminated

; ============================================================
;  [UninstallDelete] — Kaldirma sonrasi dosya temizligi
; ============================================================
[UninstallDelete]
Type: filesandordirs; Name: "{app}"

; ============================================================
;  [Code] — Pascal Script
; ============================================================
[Code]

var
  DeleteUserDataCheckbox: TNewCheckBox;

// ── Kurulum oncesi kontroller ──────────────────────────────
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;

  // 32-bit sistemde kurulumu engelle
  if not IsWin64 then
  begin
    MsgBox('SistemBakim sadece 64-bit Windows 10/11 uzerinde calisir.' + #13#10 + #13#10 +
           'Bu sistem 32-bit olarak algilandi. Kurulum iptal ediliyor.',
           mbCriticalError, MB_OK);
    Result := False;
    Exit;
  end;

  // Calisan instance'lari kapat
  Exec('taskkill', '/F /IM SistemBakim.exe /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill', '/F /IM SistemBakim_CLI.exe /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

// ── Kaldirma formu: kullanici veri temizligi secenegi ──────
procedure InitializeUninstallProgressForm();
begin
  DeleteUserDataCheckbox := TNewCheckBox.Create(UninstallProgressForm);
  DeleteUserDataCheckbox.Parent := UninstallProgressForm;
  DeleteUserDataCheckbox.Left := ScaleX(20);
  DeleteUserDataCheckbox.Top := UninstallProgressForm.StatusLabel.Top +
                                UninstallProgressForm.StatusLabel.Height + ScaleY(24);
  DeleteUserDataCheckbox.Width := ScaleX(400);
  DeleteUserDataCheckbox.Height := ScaleY(22);
  DeleteUserDataCheckbox.Caption := CustomMessage('DeleteUserData');
  DeleteUserDataCheckbox.Checked := False;
  DeleteUserDataCheckbox.Font.Style := [fsBold];
end;

// ── Kaldirma sonrasi temizlik ──────────────────────────────
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  AppDataDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Kullanici secimi: ayar/log/yedek dosyalarini temizle
    if DeleteUserDataCheckbox.Checked then
    begin
      AppDataDir := ExpandConstant('{userappdata}\SistemBakim');
      if DirExists(AppDataDir) then
        DelTree(AppDataDir, True, True, True);
    end;

    // Registry anahtarlarini temizle
    RegDeleteKeyIncludingSubkeys(HKLM, 'SOFTWARE\SistemBakim');
  end;
end;

// ── PATH tekrar ekleme kontrolu ────────────────────────────
function NeedsAddPath(Param: string): Boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKLM,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    Exit;
  end;
  // Buyuk-kucuk harf duyarsiz kontrol
  Result := Pos(';' + UpperCase(Param) + ';',
                ';' + UpperCase(OrigPath) + ';') = 0;
end;
