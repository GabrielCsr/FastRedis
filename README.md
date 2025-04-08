# FastRedis
**FastRedis** é uma biblioteca otimizada que permite mapear automaticamente objetos para o Redis, simplificando a persistência e recuperação dos dados.
## 💾 Instalação
Instalação utilizando o gerenciador de dependências boss:
```bash
boss install https://github.com/GabrielCsr/FastRedis
```
## 🔧 Configurações iniciais
Crie o arquivo `redisConfig.json` no diretório do executável para parametrização dos dados de conexão.
Estrutura do arquivo:
```bash json
{
  "Host": "127.0.0.1",
  "Port": 6379
}
```
Caso não deseje utilizar um arquivo, a parametrização também pode ser realizada manualmente da seguinte forma:
```bash pascal
TFastRedis.Configuration('127.0.0.1', 6379);
```
## ⚡ Exemplos de utilização 
```bash pascal
uses
  FastRedis;    
```
```bash pascal
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
```
Utilizando Classes:
```bash pascal
{String}
TFastRedis.Save<TAccount>('Chave:1', InstanciaTAccount, TEMPO); // salva os dados da classe em chace
TFastRedis.Load<TAccount>('Chave:1'); // Retorna uma instância da classe com as propriedades preenchidas
{Hash}
TFastRedis.Hash.Save<TAccount>('Chave:1', InstanciaTAccount); // salva os dados da classe (key e value), key sendo o nome da propriedade e value o valor da propriedade
TFastRedis.Hash.Load<TAccount>('Chave:1'); // Retorna uma instância da classe com as propriedades preenchidas;
```
Utilizando String:
```bash pascal
{String}
TFastRedis.Save('Chave:1', 'valor', TEMPO) // Salva a string em cache
TFastRedis.Load('Chave:1') // Retorna uma string
{Hash}
TFastRedis.Hash.Save('Chave:1', 'Campo', 'Valor') // salva field e value;
TFastRedis.Hash.Load('Chave:1', 'Campo'; // Retorna uma string com o valor do campo informado
```
Para mais exemplos, acesse o diretório `samples/`. Nele, você encontrará um projeto com exemplos simples de geração de cache, além de uma tela de login/cadastro com controle de expiração de acesso.

![image](https://github.com/user-attachments/assets/e6d31dfc-dfbe-4668-bf38-d69e4ef390ee) ![image](https://github.com/user-attachments/assets/6e94a18d-c1e8-47d0-b374-5b4a01e3db9a)
![image](https://github.com/user-attachments/assets/a6e42884-2361-4ad0-ac34-ce799079965c)


