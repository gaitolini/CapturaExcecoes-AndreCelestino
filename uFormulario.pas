unit uFormulario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.AppEvnts, Vcl.StdCtrls,
  JSDialog, JclDebug;

type
  TFormCapturaExcecoes = class(TForm)
    ApplicationEvents: TApplicationEvents;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Bevel: TBevel;
    Memo: TMemo;
    mmoLog: TMemo;
    btnteste: TButton;
    JSDialog1: TJSDialog;
    procedure Button1Click(Sender: TObject);
	 procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
	 procedure FormShow(Sender: TObject);
	 procedure FormCreate(Sender: TObject);
	 procedure AppException(Sender: TObject; E: Exception);
	 procedure divisao;
    procedure btntesteClick(Sender: TObject);
  end;

var
  FormCapturaExcecoes: TFormCapturaExcecoes;

implementation

uses
  System.Contnrs, uCapturaExcecoes, DBClient, uMensagem;

{$R *.dfm}
function VersaoExe: String;
	type
		PFFI = ^vs_FixedFileInfo;
	var
		F : PFFI;
		Handle : Dword;
		Len : Longint;
		Data : Pchar;
		Buffer : Pointer;
		Tamanho : Dword;
		Parquivo: Pchar;
		Arquivo,Versao : String;
		release : String;
		Parte : TStringList;
begin
		Arquivo := Application.ExeName;
		Parquivo := StrAlloc(Length(Arquivo) + 1);
		StrPcopy(Parquivo, Arquivo);
		Len := GetFileVersionInfoSize(Parquivo, Handle);
		Result := '';
		if Len > 0 then begin
			Data:=StrAlloc(Len+1);
			if GetFileVersionInfo(Parquivo,Handle,Len,Data) then begin
				VerQueryValue(Data, '\',Buffer,Tamanho);
				F := PFFI(Buffer);
				Versao := Format('%d.%d.%d.%d',
				[HiWord(F^.dwFileVersionMs),
				LoWord(F^.dwFileVersionMs),
				HiWord(F^.dwFileVersionLs),
				Loword(F^.dwFileVersionLs)]
				);

				release := Versao;
				Parte := TStringList.Create;
				try
				Parte.Clear;
				ExtractStrings(['.'],[], PChar(release), Parte);
				release := IntToStr(StrToInt64(Parte[0])+StrToInt64(Parte[1])+StrToInt64(Parte[2])+StrToInt64(Parte[3]));
				finally
				  Parte.Free;
				end;
				result := Versao;
		end;
		StrDispose(Data);
	end;
	StrDispose(Parquivo);
end;
procedure TFormCapturaExcecoes.AppException(Sender: TObject; E: Exception);
var
  DataHora: string;
  CapturaExcecoes: TCapturaExcecoes;
  Strings: TStringList;
begin
  mmoLog.Lines.Clear;
  Strings := TStringList.Create;
  CapturaExcecoes := TCapturaExcecoes.Create;

  DataHora := FormatDateTime('dd-mm-yyyy_hh-nn-ss', Now);
  mmoLog.Lines.Add('Exce��o Programada.: Victor Hugo Gonzales');
  mmoLog.Lines.Add('Data/Hora.......: ' + DateTimeToStr(Now));
  mmoLog.Lines.Add('Mensagem........: ' + E.Message);
  mmoLog.Lines.Add('Classe Exce��o..: ' + E.ClassName);

  mmoLog.Lines.Add('Formul�rio......: ' + Screen.ActiveForm.Name);
  mmoLog.Lines.Add('Unit............: ' + Sender.UnitName);
  mmoLog.Lines.Add('Controle Visual.: ' + Screen.ActiveControl.Name);
  mmoLog.Lines.Add('Usuario.........: ' + CapturaExcecoes.GetUsuario);
  mmoLog.Lines.Add('Vers�o Windows..: ' + CapturaExcecoes.GetVersaoWindows);
  //mmoLog.Lines.Add(e.GetStackInfoStringProc(e.StackInfo));
  JSDialog1.Content.Clear;
  JSDialog1.Content.Add(e.Message);
  if(JSDialog1.Execute = mrYesToAll) then begin
	  JclLastExceptStackListToStrings( Strings , True, False, True, False);
	  fMensagem.Memo1.Lines.Clear;
	  fMensagem.Memo1.Lines.Add('Exce��o Programada...: Erro desconhecido');
	  fMensagem.Memo1.Lines.Add('Analista Respons�vel.: Victor Hugo Gonzales');
	  fMensagem.Memo1.Lines.Add('Data/Hora............: ' + DateTimeToStr(Now));
	  fMensagem.Memo1.Lines.Add('Mensagem.............: ' + E.Message);
	  fMensagem.Memo1.Lines.Add('Classe Exce��o.......: ' + E.ClassName);
	  fMensagem.Memo1.Lines.Add('Formul�rio...........: ' + Screen.ActiveForm.Name);
	  fMensagem.Memo1.Lines.Add('Unit.................: ' + Sender.UnitName);
	  fMensagem.Memo1.Lines.Add('Controle Visual......: ' + Screen.ActiveControl.Name);
	  fMensagem.Memo1.Lines.Add('Usuario..............: ' + CapturaExcecoes.GetUsuario);
	  fMensagem.Memo1.Lines.Add('Vers�o Windows.......: ' + CapturaExcecoes.GetVersaoWindows);
	  fMensagem.Memo1.Lines.Add('Vers�o Aplica��o.....: ' + versaoExe);
	  fMensagem.Memo1.Lines.Add('');
	  fMensagem.Memo1.Lines.Add('Informa��o do Stack :');
	  fMensagem.Memo1.Lines.Add('');
	  fMensagem.Memo1.Lines.AddStrings(Strings);
	  fMensagem.showModal;
  end;
  mmoLog.Lines.Add(e.StackTrace);
  mmoLog.Lines.Add(StringOfChar('-', 70));
end;
procedure TFormCapturaExcecoes.ApplicationEventsException(Sender: TObject; E: Exception);
var
  CapturaExcecoes: TCapturaExcecoes;
begin
  // Cria a classe de captura de exce��es
  CapturaExcecoes := TCapturaExcecoes.Create;
  try
    // Invoca o m�todo de captura, informando os par�metros
    CapturaExcecoes.CapturarExcecao(Sender, E);

    // Carrega novamente o arquivo de log no Memo
    Memo.Lines.LoadFromFile(GetCurrentDir + '\LogExcecoes.txt');

    // Navega para o final do Memo para mostrar a exce��o mais recente
    SendMessage(Memo.Handle, EM_LINESCROLL, 0,Memo.Lines.Count);
  finally
    CapturaExcecoes.Free;
  end;
end;

procedure TFormCapturaExcecoes.btntesteClick(Sender: TObject);
begin




	divisao;
end;

procedure TFormCapturaExcecoes.Button1Click(Sender: TObject);
begin
  // EConvertError
  StrToInt('A');
end;

procedure TFormCapturaExcecoes.Button2Click(Sender: TObject);
var
  N1: integer;
  N2: integer;
  Resultado: integer;
begin
  // EDivByZero
  N1 := 10;
  N2 := 0;
  Resultado := N1 div N2;
  ShowMessage(IntToStr(Resultado));
end;

procedure TFormCapturaExcecoes.Button3Click(Sender: TObject);
var
  Lista: TObjectList;
  Objeto: TObject;
begin
  // EListError
  Lista := TObjectList.Create;
  try
    Objeto := Lista.Items[1];
    ShowMessage(Objeto.ClassName);
  finally
    Lista.Free;
  end;
end;

procedure TFormCapturaExcecoes.Button4Click(Sender: TObject);
begin
  // EFOpenError
  Memo.Lines.LoadFromFile('C:\ArquivoInexistente.txt');
end;

procedure TFormCapturaExcecoes.Button5Click(Sender: TObject);
var
  ClientDataSet: TClientDataSet;
begin
  // EDatabaseError
  ClientDataSet := TClientDataSet.Create(nil);
  try
	 ShowMessage(ClientDataSet.FieldByName('Campo').AsString);
  finally
    ClientDataSet.Free;
  end;
end;

procedure TFormCapturaExcecoes.divisao;
var
  divisor : Integer;
  conta : real;
begin
	divisor:=0;
	conta := 100/divisor;
	ShowMessage('testetetet a'+FloatToStr(conta));
end;

procedure TFormCapturaExcecoes.FormCreate(Sender: TObject);
begin
  mmoLog.Lines.Clear;
  Application.OnException := AppException;
  JclStartExceptionTracking;

end;

procedure TFormCapturaExcecoes.FormShow(Sender: TObject);
begin
  // Carrega novamente o arquivo de log no Memo
  Memo.Lines.LoadFromFile(GetCurrentDir + '\LogExcecoes.txt');
end;

end.
