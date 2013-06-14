{Unit DBUnit;
Version: 1.2;
Date of last editing: 14/06/13 10:56
Bond: SQLiteWraper, SQLite3, Vcl.Dialogs, System.SysUtils

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including procedure access to DB and execute SQL-query objects.}

unit DBUnit;

interface
uses SQLite3, SQLiteWrap, Vcl.Dialogs, System.SysUtils;

type

  //=============================================
  // One project
  TProject = record        // One project
    NameProject: string;   //Project's name
    IDProject: integer;    //ID project into DB
    CostHour:real;
    TotelHour: real;       //TODO Totel work hour
    PaymentHour: real;     //TODO oplacheno
    Pay: real              //TODO K oplate
  end;

  //Information about name of fileds DB
  TProjectInfo = record        // One project
    NameProjectField: string;   //Project's name
    IDProjectField: string;    //ID project into DB
    CostHourField: string;       //Cost Hour one filed
  end;

  //=============================================
  //One Session
  TSession = record
    IDProjectField: integer;
    StartSession: TDateTime;
    FinishSession: TDateTime;
    ClearWorkTime: integer;
  end;

  //Information about name of fileds DB
  TSessionInfo = record        // One project
    IDProjectFieldField: string;
    StartSessionField: string;   //Project's name
    FinishSessionField: string;    //ID project into DB
    ClearWorkTimeField: string;       //Cost Hour one filed
  end;

  //===============================================
  // One payment
  TPayment = record
    IDProject: integer;
    Sum: real;
    Paydate: TDate;
  end;

  //Information about name of fileds DB payment_tab
  TPaymentInfo = record        // One payment
    IDProjectField: string;
    SumField: string;
    LinkProjectField: string;
    PaymentDateField: string;
  end;

 //================================================
 //OBJECTS
 //================================================

 //Object control sessions
 TSessionControl = class (TObject)
  private
   SQLTab: TSQLiteTable;
   DB: TSQLiteDatabase;
   TableName: string;
   FieldSessionTab: TSessionInfo;
  public
   ArSession: array of TSession;   //array of sesion
   ActiveProjectID: integer;
   constructor TSessionControl (DBexe: TSQLiteDatabase; TabName: string; SessionInfo :TSessionInfo; Session :TSession);    //Inizialization array 0
   procedure AddSession (NewSession: TSession); //Add new sesion in DB
   procedure DeleteSession;
   procedure UpDateSession;
   procedure GetSession;   //Get List sesion for project
  end;

  //object control projects
 TProjectControl = class (TObject)
  private
   SQLTab: TSQLiteTable;
   DB: TSQLiteDatabase;
   TableName: string;
   FieldProjectTab: TProjectInfo;
  public
   arProject: array of TProject;                        //Array of project
   constructor TProjectControl (DBexe:TSQLiteDatabase; TabName: string; ProjectInfo :TProjectInfo); //inicializtion of array
   procedure AddProject(NewProject: TProject);           //Add new project in DB
   procedure DeleteProject (IDProject: integer);          //Delete old Project with session
   procedure ChangeProject (NewProject: TProject; IDProject: integer); //Edit project
   procedure GetArrayProject(ProjectInfo :TProjectInfo);
   end;

  //object control payments
 TPaymentControl = class (TObject)
  private
   SQLTab: TSQLiteTable;
   DB: TSQLiteDatabase;
   TableName: string;
   FieldPayTab: TPaymentInfo;
  public
   ActiveProjectID: integer;
   constructor TPaymentControl (DBexe:TSQLiteDatabase; TabName: string; ID: integer; FieldPay: TPaymentInfo);
   function GetPayment: real;                 //Get Payment for contract
   procedure SetPayment (pay: real);          //Add payment for contract
   //procedure DeletePayment                  //TODO!!!
  end;

implementation

{ TProjectControl }
constructor TProjectControl.TProjectControl(DBexe:TSQLiteDatabase; TabName: string; ProjectInfo :TProjectInfo);
var
 Query: string;
begin
try
 DB := DBexe;
 TableName := TabName;
 Query := 'SELECT * FROM ' + TableName;
 SQLTab := TSQLiteTable.Create(DB, Query);
 FieldProjectTab := ProjectInfo;
 GetArrayProject(FieldProjectTab);
except
 ShowMessage('Не удается подключится к базе данных.');
end;

end;

procedure TProjectControl.GetArrayProject(ProjectInfo :TProjectInfo);
var
 i:integer;
begin
 i := 1;
 while not (SQLTab.EOF) do
  begin
  SetLength (arProject, i);
  arProject[i-1].NameProject := SQLTab.FieldAsString(SQLTab.FieldIndex[ProjectInfo.NameProjectField]);
  arProject[i-1].IDProject := SQLTab.FieldAsInteger(SQLTab.FieldIndex[ProjectInfo.IDProjectField]);
  arProject[i-1].CostHour := SQLTab.FieldAsDouble(SQLTab.FieldIndex[ProjectInfo.CostHourField]);
  inc (i);
  SQLTab.Next;
  end;

end;


procedure TProjectControl.AddProject(NewProject: TProject);
var
 Query: string;
begin
 Query := 'INSERT INTO ' + TableName + ' ('+
  FieldProjectTab.NameProjectField  + ', '+
  FieldProjectTab.CostHourField + ') VALUES ('+
  #39 + NewProject.NameProject + #39 + ', '+
  #39 + FloatToStr(NewProject.CostHour) + #39  + ')';

 DB.ExecSQL(Query);

 SQLTab.Free;
 SQLTab := TSQLiteTable.Create(DB, 'SELECT * FROM ' + TableName);
 GetArrayProject(FieldProjectTab);
end;

procedure TProjectControl.ChangeProject(NewProject: TProject;
  IDProject: integer);
var
 Query: string;
begin
 Query := 'UPDATE ' + TableName + ' SET '+
  FieldProjectTab.NameProjectField  + ' = '+
  #39 + NewProject.NameProject + #39 + ', '+
  FieldProjectTab.CostHourField + ' = ' +
  #39 + FloatToStr(NewProject.CostHour) + #39  +
  ' WHERE ' + FieldProjectTab.IDProjectField + ' = ' + IntToStr(IDProject);

 DB.ExecSQL(Query);

 SQLTab.Free;
 SQLTab := TSQLiteTable.Create(DB, 'SELECT * FROM ' + TableName);
 GetArrayProject(FieldProjectTab);
end;

procedure TProjectControl.DeleteProject(IDProject: integer);
var
 Query:string;
begin
 Query := 'DELETE FROM ' + TableName +
  ' WHERE ' + FieldProjectTab.IDProjectField + ' = ' + IntToStr(IDProject);

 DB.ExecSQL(Query);

 SQLTab.Free;
 SQLTab := TSQLiteTable.Create(DB, 'SELECT * FROM ' + TableName);
 GetArrayProject(FieldProjectTab);
end;


{ TSessionControl }

constructor TSessionControl.TSessionControl(DBexe: TSQLiteDatabase; TabName :string; SessionInfo :TSessionInfo; Session :TSession);
begin
try
 DB := DBexe;
 TableName := TabName;
 ActiveProjectID := Session.IDProjectField;
 FieldSessionTab := SessionInfo;

 UpDateSession;
 GetSession;
except
 ShowMessage('Не удается подключится к базе данных.');
end;
end;

procedure TSessionControl.UpDateSession;
var
 Query: string;
begin
 Query := 'SELECT * FROM ' + TableName + ' WHERE ' + FieldSessionTab.IDProjectFieldField + ' = ' + IntToStr(ActiveProjectID);
 SQLTab := TSQLiteTable.Create(DB, Query);
end;

procedure TSessionControl.GetSession;
var
 i:integer;
begin

 SetLength (ArSession, 0);
 i := 1;
 while not (SQLTab.EOF) do
  begin
  SetLength (ArSession, i);
  ArSession[i-1].StartSession := StrToDateTime(SQLTab.FieldAsString(SQLTab.FieldIndex[FieldSessionTab.StartSessionField]));
  ArSession[i-1].FinishSession := StrToDateTime(SQLTab.FieldAsString(SQLTab.FieldIndex[FieldSessionTab.FinishSessionField]));
  ArSession[i-1].ClearWorkTime := SQLTab.FieldAsInteger(SQLTab.FieldIndex[FieldSessionTab.ClearWorkTimeField]);
  inc (i);
  SQLTab.Next;
  end;
end;

procedure TSessionControl.AddSession(NewSession: TSession);
var
 Query: string;
begin
 Query := 'INSERT INTO ' + TableName + ' ('+
  FieldSessionTab.IDProjectFieldField  + ', '+
  FieldSessionTab.StartSessionField  + ', '+
  FieldSessionTab.FinishSessionField  + ', '+
  FieldSessionTab.ClearWorkTimeField + ') VALUES ('+
  #39 + IntToStr(ActiveProjectID) + #39 + ', '+
  #39 + DateTimeToStr(NewSession.StartSession) + #39 + ', '+
  #39 + DateTimeToStr(NewSession.FinishSession) + #39 + ', '+
  #39 + IntToStr(NewSession.ClearWorkTime) + #39  + ')';

 DB.ExecSQL(Query);
end;

procedure TSessionControl.DeleteSession;
var
 query: string;
begin
 Query := 'DELETE FROM ' + TableName +
  ' WHERE ' + FieldSessionTab.IDProjectFieldField + ' = ' + IntToStr(ActiveProjectID);

 DB.ExecSQL(Query);
end;


{ TPaymentControl }

constructor TPaymentControl.TPaymentControl(DBexe:TSQLiteDatabase; TabName: string; ID: integer;
  FieldPay: TPaymentInfo);
begin
try
 DB := DBexe;
 TableName := TabName;
 ActiveProjectID := ID;
 FieldPayTab := FieldPay;

except
 ShowMessage('Не удается подключится к базе данных.');
end;
end;

function TPaymentControl.GetPayment: real;
var
 Query : string;
begin
 Query := 'SELECT SUM(' + FieldPayTab.SumField + ') FROM ' + TableName +
          ' WHERE ' + FieldPayTab.LinkProjectField + '=' + IntToStr(ActiveProjectID);
 SQLTab := TSQLiteTable.Create(DB, query);
 result := SQLTab.FieldAsDouble(0);
end;

procedure TPaymentControl.SetPayment(pay: real);
var
 Query : string;
begin
 Query := 'INSERT INTO ' + TableName + ' (' +
    FieldPayTab.LinkProjectField + ', '+
    FieldPayTab.SumField + ', '+
    FieldPayTab.PaymentDateField + ') VALUES ( '+
    #39 + IntToStr(ActiveProjectID) + #39 + ', ' +
    #39 + FloatToStr (pay) + #39 +  ', ' +
    #39 + DatetoStr(now) + #39 + ')';
 DB.ExecSQL(Query);
end;


end.
