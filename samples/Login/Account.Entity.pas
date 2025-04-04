unit Account.Entity;

interface

type
  TAccount = class
  private
    FUser: String;
    FString: String;
  public
    constructor Create;
    property User: String read FUser write FUser;
    property Password: String read FString write FString;
  end;

implementation

{ TAccount }

constructor TAccount.Create;
begin

end;

end.
