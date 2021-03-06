{Unit EditProjectFormUnit;
Version: 1.0;
Date of last editing: 24/04/13 22:50
Bond: SQLiteWraper

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including EditProjectFormUnit and procedure execute algorithm of UI}
unit EditProjectFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TEditProjectForm = class(TForm)
    ButtonCancel: TButton;
    ButtonSave: TButton;
    LabeledEditNameProject: TLabeledEdit;
    LabeledEditCost: TLabeledEdit;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    ProjectName: string;
    Cost: real;
    flag: boolean;
  end;

var
  EditProjectForm: TEditProjectForm;


implementation

{$R *.dfm}

procedure TEditProjectForm.ButtonCancelClick(Sender: TObject);
begin
 flag := false;
 EditProjectForm.Close;
end;

procedure TEditProjectForm.ButtonSaveClick(Sender: TObject);
begin
 try
  Cost := StrToFloat(LabeledEditCost.Text);
 except
  ShowMessage('�� ������ ������ ����� ���������.');
  exit;
 end;
 ProjectName := LabeledEditNameProject.Text;
 flag := true;
 EditProjectForm.Close;
end;

procedure TEditProjectForm.FormShow(Sender: TObject);
begin
  LabeledEditNameProject.Text := ProjectName;
  LabeledEditCost.Text := FloatToStr(Cost);
  flag := true;
end;

end.
