{Unit MainForm;
Version: 1.1;
Date of last editing: 12/05/13 14:06
Bond: ShellAPI, DBUnit

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including MainFrom and procedure for control of UI. One include calls methods of DB object}

unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls,
  Vcl.Buttons, ShellAPI, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Grids,
  DBUnit;

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
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure OnMinimizeProc(Sender: TObject);
    procedure WndProc (var Message: TMessage);
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

implementation

{$R *.dfm}

uses EditProjectFormUnit;

//Start program
procedure TMainForm.FormCreate(Sender: TObject);
var
 path, TabName: string;
 i: integer;
begin
 Application.OnMinimize := OnMinimizeProc;
 PageControl1.TabIndex := 0;
 StringGridSessions.Cells[0,0] := 'Старт сессии';
 StringGridSessions.Cells[1,0] := 'Окончание сессии';
 StringGridSessions.Cells[2,0] := 'Чистое рабочее время';

 //Get projects from DB
 GetDir (0, Path);
 Path := path + '\DB.db';
 TabName := 'PROJECT_TAB';

 with ProjInfo do
  begin
   NameProjectField := 'CAPTION';
   IDProjectField := 'ID_PROJECT';
   CostHourField := 'COST_HOUR';
  end;

 ListProject := TProjectControl.TProjectControl(path, TabName, ProjInfo);
 //Out put project's list
 ListBoxProjects.Items.Clear;
 ComboBoxProject.Items.Clear;
 for I := 0 to Length(ListProject.arProject) -1  do
  begin
    ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
    ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
  end;


end;

//close program
procedure TMainForm.N2Click(Sender: TObject);
begin
 MainForm1.close;
end;

//Aboutprogram
procedure TMainForm.N4Click(Sender: TObject);
begin
 ShowMessage('Программа для отслеживания рабочего времени. Автор: Соколовский Николай. E-mail: sokolovskynik@gmail.com');
end;

//minimimalization window in tray
procedure TMainForm.OnMinimizeProc(Sender: TObject);
begin
 Fhandle := AllocateHWnd(WndProc);
 hIcon1 := CopyIcon (Application.Icon.Handle);
 with noIconData do
  begin
    //cbSize := Sizeof(TNotifyIconData);
    Wnd := FHandle;
    uID := 0;
    uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    SzTip := 'Big Brother';
    HIcon := Hicon1;
    uCallBackMessage := Ico_message;
  end;

  Shell_NotifyIcon(NIM_ADD, @noIconData);
  MainForm1.Hide;
end;

//hooking system messages
procedure TMainForm.WndProc(var Message: TMessage);
begin
 if Message.LParam=WM_LBUTTONUP then
  begin
//    MainForm1.Show;
    DeallocateHWnd (FHandle);
    Shell_NotifyIcon(NIM_DELETE, @noIconData);// distroy tray icon
    ShowWindow(Application.Handle,SW_SHOW);   //repair buttin of program
    ShowWindow(Handle,SW_SHOW);               //show window
    {Application.Restore;
    Application.BringToFront;
    Application.ProcessMessages;}
  end;
  if Message.LParam = WM_RBUTTONUP then
   begin
     MainForm1.PopupMenu1.Popup(Screen.Width-32, Screen.Height-32);
   end;

end;

procedure TMainForm.ButtonSaveClick(Sender: TObject);
begin
 showMessage('Настройки сохранены');
end;

//Change project
procedure TMainForm.ComboBoxProjectChange(Sender: TObject);
begin
 LabelWorkProject.Caption := ComboBoxProject.Text;
 ButtonStartSession.Enabled := true;
end;

//Working with session's time
procedure TMainForm.ButtonStartSessionClick(Sender: TObject);
begin
 TimerSession.Enabled := true;
 LabelStartDT.Caption := DateTimeToStr(now);
 ButtonStartSession.Enabled := false;
 ButtonFinishSession.Enabled := true;
 ButtonPauseSession.Enabled := true;
 ComboBoxProject.Enabled := false;

 StartTime := 0;
end;

procedure TMainForm.TimerSessionTimer(Sender: TObject);
var
 sTime: string;
 i: integer;
begin
 StartTime := StartTime + 1;
 i := StartTime div 3599;
 sTime := '';
 if i < 10 then sTime := '0' + IntToStr(i)
           else sTime := IntToStr(i);

 i := StartTime div 60;
 if(i-60) >= 0 then i := i - 60;

 if i < 10 then sTime := sTime + ':0' + IntToStr(i)
           else sTime := sTime + ':' + IntToStr(i);

 i := StartTime mod 60;
 if i < 10 then sTime := sTime + ':0' + IntToStr(i)
           else sTime := sTime + ':' + IntToStr(i);

 LabelTimeCount.Caption := sTime;

end;

procedure TMainForm.ButtonPauseSessionClick(Sender: TObject);
begin
 if ButtonPauseSession.Caption = 'Пауза' then
  begin
    TimerSession.Enabled := false;
    ButtonPauseSession.Caption := 'Продолжить';
  end
  else
  begin
    TimerSession.Enabled := true;
    ButtonPauseSession.Caption := 'Пауза';
  end;


end;

procedure TMainForm.ButtonFinishSessionClick(Sender: TObject);
begin
 TimerSession.Enabled := false;
 ButtonStartSession.Enabled := true;
 ButtonFinishSession.Enabled := false;
 ButtonPauseSession.Enabled := false;
 ComboBoxProject.Enabled := true;
end;

//Job with payment
procedure TMainForm.ButtonGetPaymentClick(Sender: TObject);
var
str:string;
begin
 if ListBoxProjects.ItemIndex < 0 then
  begin
    ShowMessage('Выберите проект для вноса оплаты.');
    exit;
  end;

 str := InputBox('Ввод оплаты', 'Введите полученную сумму в $ по проекту: ' + ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex], '0');
 ShowMessage(Str);

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
     ShowMessage('Проект добавлен.');
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
  finally
   ListBoxProjects.Items.Clear;
   ComboBoxProject.Items.Clear;
   for I := 0 to Length(ListProject.arProject) -1  do
     begin
      ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
      ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
     end;
   ShowMessage('Проект изменен.');
  end;
  end;

end;

//DELETE Project
procedure TMainForm.ButtonDeleteProjectClick(Sender: TObject);
var
ID, i :integer;
begin
 if ListBoxProjects.ItemIndex < 0 then
  begin
    ShowMessage('Выберите проект для удаления.');
    exit;
  end;

 if MessageDlg('Вы действительно хотите удалить все данные связанные с проектом ' + ListBoxProjects.Items.Strings[ListBoxProjects.ItemIndex],
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
         break;
        end;
      end;
     finally
      ListBoxProjects.Items.Clear;
      ComboBoxProject.Items.Clear;
      for I := 0 to Length(ListProject.arProject) -1  do
        begin
         ListBoxProjects.Items.Add(ListProject.arProject[i].NameProject);
         ComboBoxProject.Items.Add(ListProject.arProject[i].NameProject);
        end;
      ShowMessage('Проект удален.');
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
