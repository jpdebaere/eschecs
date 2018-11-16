
unit Engines;

interface

uses
  SysUtils,
  fpJSON,
  JSONParser,
  IOUtils;
  
type
  TEngineInfo = record
    vCommand, vName, vDirectory: string;
    vExists: boolean;
  end;

var
  vEngines: array of TEngineInfo;

procedure LoadEnginesData(const aFileName: TFileName);

implementation

procedure LoadEnginesData(const aFileName: TFileName);
var
  vData: TJSONData;
  i: integer;
begin
  Assert(FileExists(aFileName));
  vData := GetJSON(TFile.ReadAllText(aFileName));
  if vData.JSONType = jtArray then
  begin
    SetLength(vEngines, vData.Count);
    for i := 0 to vData.Count - 1 do
      with vEngines[i] do
      begin
        vCommand := vData.Items[i].FindPath('command').AsString;
        vName := vData.Items[i].FindPath('name').AsString;
        vDirectory := ExtractFileDir(ParamStr(0)) + vData.Items[i].FindPath('workingDirectory').AsString;
        vExists := FileExists(Concat(vDirectory, vCommand));
      end;
  end;
  vData.Free;
end;

end.
