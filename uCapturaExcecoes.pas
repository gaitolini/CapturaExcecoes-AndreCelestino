unit uCapturaExcecoes;


interface


uses
  System.SysUtils;

type
  TCapturaExcecoes = class
  public
    function GetUsuario: string;
    function GetVersaoWindows: string;
	 procedure GravarImagemTela(const NomeArquivo: string);

  public
    procedure CapturarExcecao(Sender: TObject; E: Exception);
  end;

implementation

uses
  Winapi.Windows,System.Win.Registry, System.UITypes,
  Vcl.Forms, Vcl.Dialogs, Vcl.Graphics, Vcl.Imaging.jpeg, Vcl.ClipBrd,
  Vcl.ComCtrls;

{ TCapturaExcecoes }
procedure TCapturaExcecoes.CapturarExcecao(Sender: TObject; E: Exception);
var
  CaminhoArquivoLog: string;
  ArquivoLog: TextFile;
  //StringBuilder: TStringBuilder;
  DataHora: string;
begin
  CaminhoArquivoLog := GetCurrentDir + '\LogExcecoes.txt';
  AssignFile(ArquivoLog, CaminhoArquivoLog);

  // Se o arquivo existir, abre para edi��o,
  // Caso contr�rio, cria o arquivo
  if FileExists(CaminhoArquivoLog) then
    Append(ArquivoLog)
  else
    ReWrite(ArquivoLog);

  DataHora := FormatDateTime('dd-mm-yyyy_hh-nn-ss', Now);
  WriteLn(ArquivoLog, 'Data/Hora.......: ' + DateTimeToStr(Now));
  WriteLn(ArquivoLog, 'Mensagem........: ' + E.Message);
  WriteLn(ArquivoLog, 'Classe Exce��o..: ' + E.ClassName);
  WriteLn(ArquivoLog, 'Formul�rio......: ' + Screen.ActiveForm.Name);
  WriteLn(ArquivoLog, 'Unit............: ' + Sender.UnitName);
  WriteLn(ArquivoLog, 'Controle Visual.: ' + Screen.ActiveControl.Name);
  WriteLn(ArquivoLog, 'Usuario.........: ' + GetUsuario);
  WriteLn(ArquivoLog, 'Vers�o Windows..: ' + GetVersaoWindows);
  WriteLn(ArquivoLog, StringOfChar('-', 70));

  // Fecha o arquivo
  CloseFile(ArquivoLog);

  GravarImagemTela(DataHora);

  { * Descomente esse c�digo para que a exce��o seja exibida para o usu�rio *
  StringBuilder := TStringBuilder.Create;
  try
    // Exibe a mensagem para o usu�rio
    StringBuilder.AppendLine('Ocorreu um erro na aplica��o.')
      .AppendLine('O problema ser� analisado pelos desenvolvedores.')
      .AppendLine(EmptyStr)
      .AppendLine('Descri��o t�cnica:')
      .AppendLine(E.Message);

    MessageDlg(StringBuilder.ToString, mtWarning, [mbOK], 0);
  finally
    StringBuilder.Free;
  end;}
end;

procedure TCapturaExcecoes.GravarImagemTela(const NomeArquivo: string);
var
  DesktopDC: HDC;
  Bitmap: TBitmap;
  JPEG: TJpegImage;
begin
  DesktopDC := GetWindowDC(GetDesktopWindow);
  Bitmap := TBitmap.Create;
  JPEG := TJpegImage.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Height := Screen.Height;
    Bitmap.Width := Screen.Width;
    BitBlt(Bitmap.Canvas.Handle, 0, 0, Bitmap.Width, Bitmap.Height, DesktopDC, 0, 0, SRCCOPY);
    JPEG.Assign(Bitmap);
    JPEG.SaveToFile(Format('%s\%s.jpg', [GetCurrentDir, NomeArquivo]));
  finally
    JPEG.Free;
    Bitmap.Free;
    ReleaseDC(GetDesktopWindow, DesktopDC);
  end;
end;

function TCapturaExcecoes.GetUsuario: string;
var
  Size: DWord;
begin
  // retorna o login do usu�rio do sistema operacional
  Size := 1024;
  SetLength(result, Size);
  GetUserName(PChar(result), Size);
  SetLength(result, Size - 1);
end;

function TCapturaExcecoes.GetVersaoWindows: string;
begin
  case Win32MajorVersion of
	 5:
		case Win32MinorVersion of
		  0: result := 'Windows 2000';
		  1: result := 'Windows XP';
		  2: Result := 'Windows XP 64-Bit Edition / Windows Server 2003 / Windows Server 2003 R2';
		end;
	 6:
		case Win32MinorVersion of
		  0: result := 'Windows Vista / Windows Server 2008';
		  1: result := 'Windows 7 / Windows Server 2008 R2';
		  2: result := 'Windows 8 / Windows Server 2012';
		  3: result := 'Windows 8.1 / Windows Server 2012 R2';
		end;
	 10:
		case Win32MinorVersion of
		  0: result := 'Windows 10 / Windows Server 2016';
		end;
  end;
end;

end.
