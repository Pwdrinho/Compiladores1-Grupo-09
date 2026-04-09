# Manual de Instalação do Flex e Bison (Linux e Windows)

## 1. Introdução

O **flex** (Fast Lexical Analyzer Generator) e o **Bison** (GNU Parser Generator) são ferramentas amplamente utilizadas na construção de compiladores e interpretadores.

- *Flex* é usado para gerar **analisadores léxicos**.
- *Bison* é usado para gerar **analisadores sintáticos**.

Essas ferramentas são tradicionalmente utilizadas em ambiente **Unix/Linux**, mas também podem ser usadasd no ***Windows* através do *WSL*** (*Windows Subsystem for Linux*).

## 2. Instalação no Linux

A instalação em sistemas Linux é simples, pois os pacotes geralmente já estão disponíveis nos repositórios das distribuições.

### 2.1 Ubuntu / Debian

Atualize os repositórios:

``` bash
sudo apt update
```

Instale o Flex e o Bison:

``` bash
sudo apt install flex bison
```

Opcionalmente, instale também o compilador GCC:

``` bash
sudo apt install build-essential
```

### 2.2 Verificação da instalação

Após a instalação, verifique se as ferramentas estão disponíveis:

``` bash
flex --version
bison --version
```

Se a instalação foi bem-sucedida, o terminal exibirá as versões
instaladas.

## 3. Instalação no Windows (usando WSL)

No Windows, recomenda-se utilizar o **WSL (Windows Subsystem for Linux)**, pois ele fornece um ambiente Linux completo dentro do sistema.

### 3.1 Instalar o WSL

Abra o **PowerShell como administrador** e execute para a instalação do *WSl*:

``` powershell
wsl --install
```

``` powershell
wsl --list --online
```
O comando acima listará todas as distribuições disponíveis para a instalação, recomenda-se utilizar o Ubuntu utilizando o comando:
``` powershell
wsl --install Ubuntu
```

Após a instalação, **reinicie o computador**.

### 3.2 Abrir o Ubuntu no WSL

Depois de reiniciar:

1.  Abra o menu iniciar;
2.  Procure por **Ubuntu**;
3.  Execute o terminal.

Na primeira execução será solicitado:

-   criação de **usuário**;
-   criação de **senha**.

### 3.3 Atualizar o sistema

Dentro do terminal do Ubuntu:

``` bash
sudo apt update
sudo apt upgrade
```

### 3.4 Instalar Flex e Bison

Execute:

``` bash
sudo apt install flex bison build-essential git -y
```

### 3.5 Verificação de instalação

Após a instalação, verifique se as ferramentas estão disponíveis:

``` bash
flex --version
bison --version
```