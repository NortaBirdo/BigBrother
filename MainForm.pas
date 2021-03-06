{Unit MainForm;
Version: 1.6;
Date of last editing: 27/08/13 9:35
Bond: ShellAPI, DBUnit, DateTimeTransformUnit

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including MainFrom and procedure for control of UI. One include calls methods of DB object}

unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls,
  Vcl.Buttons, ShellAPI, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Grids,
  DBUnit, DateUtils;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    PageControl1: TPageControl;
    TabSheetSession: TTabSheet;
    TabSheetProject: TTabSheet;
    TabSheetSetting: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelStartDT: TLabel;
    LabelTimeCount: TLabel;
    ComboBoxProject: TComboBox;
    LabelWorkProject: TLabel;
    ButtonFinishSession: TBitBtn;
    ButtonPauseSession: TBitBtn;
    ButtonStartSession: TBitBtn;
    PopupMenu1: TPopupMenu;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    ImageList1: TImageList;
    Label5: TLabel;
    ButtonEditProject: TBitBtn;
    ButtonDeleteProject: TBitBtn;
    Splitter1: TSplitter;
    ButtonAddProject: TBitBtn;
    ButtonGetPayment: TBitBtn;
    ListBoxProjects: TListBox;
    StringGridSessions: TStringGrid;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    LabelTotelHours: TLabel;
    LabelPayedHours: TLabel;
    LabelChekHours: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    UpDown1: TUpDown;
    EditWorkTime: TEdit;
    UpDown2: TUpDown;
    EditBreakTime: TEdit;
    EditMessageTime: TEdit;
    CheckBoxIsControl: TCheckBox;
    ButtonSave: TBitBtn;
    UpDown3: TUpDown;
    TimerSession: TTimer;
    Label17: TLabel;
    LabelCost: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonStartSessionClick(Sender: TObject);
    procedure TimerSessionTimer(Sender: TObject);
    procedure ButtonFinishSessionClick(Sender: TObject);
    procedure ButtonPauseSessionClick(Sender: TObject);
    procedure ComboBoxProjectChange(Sender: TObject);
    procedure ButtonGetPaymentClick(Sender: TObject);
    procedure ButtonAddProjectClick(Sender: TObject);
    procedure ButtonEditProjectClick(Sender: TObject);
    procedure ButtonDeleteProjectClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure CheckBoxIsControlClick(Sender: TObject);
    procedure ListBoxProjectsClick(Sender: TObject);
    function CalcTime: integer;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm1: TMainForm;
  {Variable for tray}
  Ico_message:integer = wm_USER;
  noIconData: TNotifyIconData;
  HIcon1: hIcon;
  FHandle: HWnd;
  //variable
  StartTime: integer = 0;
  ListProject: TProjectControl;
  ProjInfo: TProjectInfo;
  OneProject: TProject;

  SessInfo: TSessionInfo;
  OneSession: TSession;
  ListSession :TSessionControl;

  Pay: TPaymentInfo;
  PayList: TPaymentControl;

implementation

{$R *.dfm}

uses EditProjectFormUnit, DateTimeTransformUnit, MyUtilsUnit, SQLiteWrap,
  SQLite3;

//Start program
procedure TMainForm.FormCreate(Sender: TObject);
var
 path, TabName: string;
 i: integer;
 DB: TSQLiteDatabase;
begin
 PageControl1.TabIndex := 0;
 StringGridSessions.Cells[0,0] := '����� ������';
 StringGridSessions.Cells[1,0] := '��������� ������';
 StringGridSessions.Cells[2,0] := '������ ������� �����';

 //Get projects from DB
 GetDir (0, Path);
 Path := path + '\DB.db';

 DB := TSQLiteDatabase.Create(path);
 TabName := 'PROJECT_TAB';


 with ProjInfo do
  begin
   NameProjectField := 'CAPTION';
   IDProjectField := 'ID_PROJECT';
   CostHourField := 'COST_HOUR';
  end;

 ListProject := TProjectControl.TProjectControl(DB, TabName, ProjInfo);
 //Out put project's list
 ListBoxProjects.Items.Clear;
 ComboBoxProject.Items.Clear;
 for I := 0 to Length(ListProject.arProject) -1  do
  begin
    ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
    ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
  end;

 //prepare info for session object
 TabName := 'SESSION_TAB';

 with SessInfo do
  begin
   IDProjectFieldField := 'L_PROJ';
   StartSessionField := 'START_DATE';
   FinishSessionField := 'FINISH_DATE';
   ClearWorkTimeField := 'CLEAR_WORK_TIME';
  end;

 if Length(ListProject.arProject) = 0 then exit;

 OneSession.IDProjectField := ListProject.arProject[0].IDProject;
 ListSession := TSessionControl.TSessionControl(DB, TabName, SessInfo, OneSession);
 LabelCost.Caption := FloatToStrF(ListProject.arProject[0].CostHour, ffFixed, 0,1);

 StringGridSessions.RowCount := Length (ListSession.ArSession) + 1;
 for I := 0 to Length (ListSession.ArSession) - 1 do
   begin
    StringGridSessions.Cells[0, i + 1] := DateTimeToStr(ListSession.ArSession[i].StartSession);
    StringGridSessions.Cells[1, i + 1] := DateTimeToStr(ListSession.ArSession[i].FinishSession);
    StringGridSessions.Cells[2, i + 1] := IntToDateTimeStr(ListSession.ArSession[i].ClearWorkTime);
   end;
 CalcTime;

 TabName := 'PAYMENT_TAB';

 with Pay do
  begin
    IDProjectField := 'ID_PAY';
    LinkProjectField := 'L_PROJECT';
    SumField := 'PAYMENT_SUM';
    PaymentDateField := 'PAYMENT_DATE';
  end;

 PayList := TPaymentControl.TPaymentControl(DB, TabName, ListProject.arProject[0].IDProject, Pay);
 LabelPayedHours.Caption := FloatToStr(PayList.GetPayment);

end;

//Out put Sessiones
procedure TMainForm.ListBoxProjectsClick(Sender: TObject);
var
 path, TabName: string;
 i: integer;
 iCalcTime, r :integer;
begin

 if ListBoxProjects.Items.Count = 0 then exit;
 if ListBoxProjects.ItemIndex < 0 then exit;

 //CLEAR TABLE
 StringGridSessions.RowCount := 1;

 //find project and get session and payment
   for I := 0 to Length(ListProject.arProject) -1  do
    if ListProject.arProject[i].NameProject =  ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex] then
      begin
       //Prepare Object
       ListSession.ActiveProjectID := ListProject.arProject[i].IDProject;
       PayList.ActiveProjectID := ListProject.arProject[i].IDProject;

       //Get Cost Hour and Paymnts
       LabelCost.Caption := FloatToStrF(ListProject.arProject[i].CostHour, ffFixed, 0, 1);
       LabelPayedHours.Caption := FloatToStr(PayList.GetPayment);

       //calc payed time
       iCalcTime := CalcPayedTime(PayList.GetPayment, ListProject.arProject[i].CostHour);
      end;


 ListSession.UpDateSession;
 ListSession.getsession;
 //Out put project's list
 StringGridSessions.RowCount := Length (ListSession.ArSession) + 1;
 for I := 0 to Length (ListSession.ArSession) - 1 do
   begin
    StringGridSessions.Cells[0, i + 1] := DateTimeToStr(ListSession.ArSession[i].StartSession);
    StringGridSessions.Cells[1, i + 1] := DateTimeToStr(ListSession.ArSession[i].FinishSession);
    StringGridSessions.Cells[2, i + 1] := IntToDateTimeStr(ListSession.ArSession[i].ClearWorkTime);
   end;

 r := CalcTime;
 LabelTotelHours.Caption := IntToDateTimeStr(r);
 //������ �������������� ��� ����������.
 LabelPayedHours.Caption := IntToDateTimeStr(iCalcTime);
 if (r - iCalcTime)<0 then LabelChekHours.Caption := '-' + IntToDateTimeStr(abs(r - iCalcTime))
                      else LabelChekHours.Caption := IntToDateTimeStr(r - iCalcTime);

end;

//Calculation Time
function TMainForm.CalcTime: integer;
var
i :integer;
TotelCountTime: integer;
t:TTime;                                      
begin
TotelCountTime := 0;
if Length(ListSession.ArSession) <> 0 then
   for I := 0 to Length(ListSession.ArSession) - 1 do
    TotelCountTime := TotelCountTime + ListSession.ArSession[i].ClearWorkTime;

 result := TotelCountTime;
end;

//close program
procedure TMainForm.N2Click(Sender: TObject);
begin
 MainForm1.close;
end;

//Aboutprogram
procedure TMainForm.N4Click(Sender: TObject);
begin
 ShowMessage('��������� ��� ������������ �������� �������. �����: ����������� �������. E-mail: sokolovskynik@gmail.com');
end;

procedure TMainForm.ButtonSaveClick(Sender: TObject);
begin
 showMessage('��������� ���������');
end;

//Change project
procedure TMainForm.ComboBoxProjectChange(Sender: TObject);
begin
 LabelWorkProject.Caption := ComboBoxProject.Text;
 ButtonStartSession.Enabled := true;
end;

//Working with session's time
procedure TMainForm.ButtonStartSessionClick(Sender: TObject);
var
 i: integer;
begin
 TimerSession.Enabled := true;
 LabelStartDT.Caption := DateTimeToStr(now);
 ButtonStartSession.Enabled := false;
 ButtonFinishSession.Enabled := true;
 ButtonPauseSession.Enabled := true;
 ComboBoxProject.Enabled := false;

 for I := 0 to Length(ListProject.arProject) -1  do
   if ListProject.arProject[i].NameProject =  ComboBoxProject.Items.Strings[ComboBoxProject.ItemIndex] then
      ListSession.ActiveProjectID := ListProject.arProject[i].IDProject;
 OneSession.StartSession := now;

 StartTime := 0;
end;

procedure TMainForm.TimerSessionTimer(Sender: TObject);
var
 i: integer;
begin
 StartTime := StartTime + 1;
 LabelTimeCount.Caption := IntToDateTimeStr(StartTime);
end;

procedure TMainForm.ButtonPauseSessionClick(Sender: TObject);
begin
 if ButtonPauseSession.Caption = '�����' then
  begin
    TimerSession.Enabled := false;
    ButtonPauseSession.Caption := '����������';
  end
  else
  begin
    TimerSession.Enabled := true;
    ButtonPauseSession.Caption := '�����';
  end;


end;

procedure TMainForm.ButtonFinishSessionClick(Sender: TObject);
var
 I :integer;
begin
 TimerSession.Enabled := false;
 ButtonStartSession.Enabled := true;
 ButtonFinishSession.Enabled := false;
 ButtonPauseSession.Enabled := false;
 ComboBoxProject.Enabled := true;

 OneSession.FinishSession := now;
 OneSession.ClearWorkTime :=  StartTime;
 ListSession.AddSession(OneSession);
 ListBoxProjectsClick(sender);
end;

//Add project payment
procedure TMainForm.ButtonGetPaymentClick(Sender: TObject);
var
str:string;
sumpay:real;
i: integer;
begin
 if ListBoxProjects.ItemIndex < 0 then
  begin
    ShowMessage('�������� ������ ��� ����� ������.');
    exit;
  end;

 str := InputBox('���� ������', '������� ������ ������� � $ �� �������: ' + ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex], '0');
 try
  sumPay := StrToFloat(str);
 except
  ShowMessage('�� ������ ������ ����� ��� �������� �����.');
  exit;
 end;

 for I := 0 to Length(ListProject.arProject) -1  do
    if ListProject.arProject[i].NameProject =  ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex] then
       PayList.ActiveProjectID := ListProject.arProject[i].IDProject;

 PayList.SetPayment(SumPay);
 ListBoxProjectsClick(sender);

end;

//job with project
//Add NEW project
procedure TMainForm.ButtonAddProjectClick(Sender: TObject);
var
str: string;
i: integer;
begin
 EditProjectform.ProjectName := '';
 EditProjectform.Cost := 0;
 EditProjectform.ShowModal;
 if EditProjectform.flag then
  //If press button "Ok"
  begin
   OneProject.NameProject := EditProjectform.ProjectName;
   OneProject.CostHour := EditProjectform.Cost;
   try
    ListProject.AddProject(OneProject);
   finally
     ListBoxProjects.Items.Clear;
     ComboBoxProject.Items.Clear;
      for I := 0 to Length(ListProject.arProject) -1  do
        begin
        ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
        ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
        end;
     ShowMessage('������ ��������.');
     ListBoxProjectsClick(sender);
   end;
  end;
end;

// EDIT project
procedure TMainForm.ButtonEditProjectClick(Sender: TObject);
var
str: string;
i, ID: integer;
begin
 //finding project's ID
 if ListBoxProjects.ItemIndex < 0 then
   begin
    ShowMessage('�������� ������ ��� ���������.');
    exit;
  end;

 for I := 0 to Length(ListProject.arProject) - 1 do
  begin
    if ListProject.arProject[i].NameProject =
      ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex] then
      begin
       ID := ListProject.arProject[i].IDProject;
       EditProjectform.ProjectName := ListProject.arProject[i].NameProject;
       EditProjectform.Cost := ListProject.arProject[i].CostHour;
       break;
      end;
  end;


 EditProjectform.ShowModal;

 if EditProjectform.flag then
  //If press button "Ok"
  begin
  OneProject.NameProject := EditProjectform.ProjectName;
  OneProject.CostHour := EditProjectform.Cost;
  try
   ListProject.ChangeProject(OneProject, ID);
  except
   ShowMessage('������ ������� � ����');
  end;

   ListBoxProjects.Items.Clear;
   ComboBoxProject.Items.Clear;
   for I := 0 to Length(ListProject.arProject) -1  do
     begin
      ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
      ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
     end;
   ShowMessage('������ �������.');
  end;

end;

//DELETE Project
procedure TMainForm.ButtonDeleteProjectClick(Sender: TObject);
var
ID, i :integer;
begin
 if ListBoxProjects.ItemIndex < 0 then
  begin
    ShowMessage('�������� ������ ��� ��������.');
    exit;
  end;

 if MessageDlg('�� ������������� ������ ������� ��� ������ ��������� � �������� ' + ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex] + '?',
    mtConfirmation, mbYesNo, 0) = idYes then
    begin
    try
     for I := 0 to Length(ListProject.arProject) - 1 do
      begin
       if ListProject.arProject[i].NameProject =
        ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex] then
        begin
         ID := ListProject.arProject[i].IDProject;
         ListProject.DeleteProject(ID);
         ListSession.ActiveProjectID := ID;
         ListSession.DeleteSession;
         break;
        end;
      end;
     finally
      ListBoxProjects.Items.Clear;
      ComboBoxProject.Items.Clear;
      for I := 0 to Length(ListProject.arProject) - 1  do
        begin
         ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
         ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
        end;
      StringGridSessions.RowCount := 1;
      ShowMessage('������ ������.');
     end;
    end;

end;

//Job with setting
procedure TMainForm.CheckBoxIsControlClick(Sender: TObject);
begin
if not(CheckBoxIsControl.Checked) then
 begin
  UpDown1.Enabled := false;
  UpDown2.Enabled := false;
  UpDown3.Enabled := false;
  EditWorkTime.Enabled := false;
  EditBreakTime.Enabled := false;
  EditMessageTime.Enabled := false;
  ButtonSave.Enabled := false;
 end
 else
 begin
  UpDown1.Enabled := true;
  UpDown2.Enabled := true;
  UpDown3.Enabled := true;
  EditWorkTime.Enabled := true;
  EditBreakTime.Enabled := true;
  EditMessageTime.Enabled := true;
  ButtonSave.Enabled := true;
 end;
end;

end.
