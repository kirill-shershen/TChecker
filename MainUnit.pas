unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCallerForm = class(TForm)
    lPhone: TLabel;
    ePhone: TEdit;
    bExecute: TButton;
    log: TMemo;
    bStop: TButton;
    procedure bExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure SetEnabled(const AEnabled: boolean);
  public
    { Public declarations }
  end;

  TCallerThread = class(TThread)
    URL: string;
    vStr: TStringList;
    vCallSid: string;
  private
  protected
    procedure Execute; override;
  published
  end;
var
  CallerForm: TCallerForm;
  Caller: TCallerThread;
  closing: boolean;
implementation
  uses
    httpsend;

{$R *.dfm}

function StreamToString(Stream : TStream) : String;
var ms : TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result,PChar(ms.memory),ms.Size);
  finally
    ms.free;
  end;
end;

procedure TCallerForm.bExecuteClick(Sender: TObject);
var
  err:boolean;
  HTTPSender: THTTPSend;
  vCallSid: string;
begin
  try
    // clear log
    log.lines.clear;
    err := False;
    // create request
    HTTPSender := THTTPSend.Create;
    HTTPSender.HTTPMethod('GET', format('http://cloudzapcaller.appspot.com/dial?to=%s',[ePhone.Text]));
    //response to string
    vCallSid := StreamToString(HTTPSender.Document);
    if HTTPSender.ResultCode = 500 then
    Begin
      MessageBox(handle, PAnsiChar('Error communicating with web application or invalid phone no.'), PAnsiChar('Error'), MB_OK+MB_ICONERROR);
      err := True;
    end
    else
      if copy(vCallSid, 0, 2) <> 'CA' then
      Begin
        MessageBox(handle, PAnsiChar(format('Error placing call: %s',[vCallSid])), PAnsiChar('Error'), MB_OK+MB_ICONERROR);
        err := True;
      end;
    if not err then
    Begin
      // disable controls
      SetEnabled(False);
      //run thread with params
      Caller := TCallerThread.Create(True);
      Caller.vCallSid := vCallSid;
      Caller.Resume;
    end;  
  finally
    FreeAndNil(HTTPSender);
  end;
end;

{ TCallerThread }

procedure TCallerThread.Execute;
var
  HTTPSender: THTTPSend;
begin
  inherited;
  CallerForm.log.lines.add('Waiting 30 seconds initially.');
  sleep(10000);
  while True do
  Begin
    sleep(20000);
    try
      if self.Terminated then
      Begin
        CallerForm.log.lines.add('Thread detected closing. Terminating call.');
        HTTPSender := THTTPSend.Create;
        HTTPSender.HTTPMethod('GET', format('http://cloudzapcaller.appspot.com/hangup?CallSid=%s',[self.vCallSid]));
        HTTPSender.Free;
        CallerForm.SetEnabled(True);
        break;
      end;
      CallerForm.log.lines.add('Checking CallSid ' + self.vCallSid);
      // create request
      HTTPSender := THTTPSend.Create;
      HTTPSender.HTTPMethod('GET', format('http://cloudzapcaller.appspot.com/check?CallSid=%s',[self.vCallSid]));
      // response to string
      self.URL := StreamToString(HTTPSender.Document);
      // if not found then continue wait
      if HTTPSender.ResultCode = 404 then
      begin
         CallerForm.log.lines.add(format('CallSid %s 404''d',[self.vCallSid]));
         Continue;
      end
      else
      if copy(self.URL, 0, 4) = 'http' then
        CallerForm.log.lines.add('\nSuccess ' + self.URL)
      else
        CallerForm.log.lines.add('CallSid ' + self.URL);
      HTTPSender.Free;
      CallerForm.SetEnabled(True);
			break;
    except
      on E : Exception do
      Begin
        CallerForm.log.lines.add(format('There was an issue accessing the web application (%s)', [e.message]));
        CallerForm.SetEnabled(True);
        Break;
      end;  
    end
  end;
end;

procedure TCallerForm.SetEnabled(const AEnabled: boolean);
begin
  lPhone.Enabled := AEnabled;
  ePhone.Enabled := AEnabled;
  bExecute.Enabled := AEnabled;
  bStop.Enabled := not AEnabled;  
end;

procedure TCallerForm.FormCreate(Sender: TObject);
begin
  SetEnabled(True);
  closing := False;
end;

procedure TCallerForm.bStopClick(Sender: TObject);
begin
  //if you want to check another phone
  if not Caller.Terminated then
  Begin
    Caller.Terminate;
    Caller.WaitFor;
    Caller.Free;
    SetEnabled(True);
  End;
end;

procedure TCallerForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Assigned(Caller) and not Caller.Terminated then
  Begin
    closing := True;
    Caller.Terminate;
    Caller.WaitFor;
    Caller.Free;
    CanClose := True;
  End else
    CanClose := True;
end;

end.
