{Unit DBUnit;
Version: 1.1;
Date of last editing: 12/05/13 14:06
Bond: SQLiteWraper, SQLite3, Vcl.Dialogs, System.SysUtils

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including procedure access to DB and execute SQL-query objects.}

unit DBUnit;

interface
uses SQLite3, SQLiteWrap, Vcl.Dialogs, System.SysUtils;

type
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


  //One Session
  TSession = record
    StartSession: string;
    FinishSession: string;
    ClearWorkTime: string;
  end;

  //Object control sessions
 TSessionControl = class (TObject)
   arSession: array of TSession;   //array of sesion
   constructor TSessionControl;    //Inizialization array 0
   function AddSession (NewSession: TSession):boolean; //Add new sesion in DB
   procedure DeleteSession (ID: integer);
   procedure GetSession;                               //Get List sesion for project
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
   constructor TProjectControl (path, TabName: string; ProjectInfo :TProjectInfo); //inicializtion of array
   procedure AddProject(NewProject: TProject);           //Add new project in DB
   procedure DeleteProject (IDProject: integer);          //Delete old Project with session
   procedure ChangeProject (NewProject: TProject; IDProject: integer); //Edit project
   procedure GetArrayProject(ProjectInfo :TProjectInfo);
   end;


implementation

{ TProjectControl }
constructor TProjectControl.TProjectControl(path, TabName: string; ProjectInfo :TProjectInfo);
var
 Query: string;
begin
try
 DB := TSQLiteDatabase.Create(path);
 TableName := TabName;
 Query := 'SELECT * FROM ' + TableName;
 SQLTab := TSQLiteTable.Create(DB, Query);
 FieldProjectTab := ProjectInfo;
 GetArrayProject(FieldProjectTab);
except
 ShowMessage('�� ������� ����������� � ���� ������.');
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

function TSessionControl.AddSession(NewSession: TSession): boolean;
begin
//
end;

procedure TSessionControl.DeleteSession(ID: integer);
begin
    //
end;

procedure TSessionControl.GetSession;
begin
  //
end;

constructor TSessionControl.TSessionControl;
begin
//
end;

end.