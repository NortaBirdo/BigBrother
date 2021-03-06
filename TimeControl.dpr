program TimeControl;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainForm},
  DBUnit in 'DBUnit.pas',
  EditProjectFormUnit in 'EditProjectFormUnit.pas' {EditProjectForm},
  SQLite3 in 'SQLite3.pas',
  SQLiteWrap in 'SQLiteWrap.pas',
  DateTimeTransformUnit in 'DateTimeTransformUnit.pas',
  MyUtilsUnit in 'MyUtilsUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Big Brother';
  Application.CreateForm(TMainForm, MainForm1);
  Application.CreateForm(TEditProjectForm, EditProjectForm);
  Application.Run;
end.
