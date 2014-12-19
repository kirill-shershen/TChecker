program CloudZap_Caller;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'CloudZap Caller';
  Application.CreateForm(TCallerForm, CallerForm);
  Application.Run;
end.
