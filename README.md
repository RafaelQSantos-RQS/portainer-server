# Portainer Server: Gestão de Contêineres como Serviço

<!-- markdownlint-disable-next-line MD033 -->
<p align="center"><img src="https://github.com/portainer/portainer/blob/develop/app/assets/images/portainer-github-banner.png?raw=true" alt="Portainer Banner" title="portainer"></p>

## 🎯 Visão Geral

Este projeto implanta uma instância do **Portainer Community Edition** de forma robusta e padronizada, projetada para se integrar a uma infraestrutura on-premise que já utiliza o Traefik como proxy reverso.

O Portainer servirá como nossa interface gráfica de gerenciamento (GUI) para o ambiente Docker, oferecendo uma visão clara e controle sobre contêineres, volumes, redes e outros recursos. A implantação é gerenciada por um `Makefile`, garantindo que o setup e a manutenção sejam processos simples e à prova de erros.

## 🏗️ Arquitetura e Decisões de Design

A estabilidade vem de um design deliberado. Este serviço não é uma ilha; ele foi projetado para ser um cidadão de primeira classe na nossa infraestrutura conteinerizada.

1. **Integração com o Proxy Reverso (Traefik):** O `docker-compose.yaml` já vem com as *labels* necessárias para que o Traefik descubra, exponha e proteja o Portainer automaticamente via HTTPS. Não há exposição de portas diretas no host; o acesso é centralizado na portaria.
2. **Rede e Volume Externos:** O serviço se conecta a uma rede Docker externa (padrão: `web`) e utiliza um volume Docker externo (padrão: `portainer-server-data`). Isso é crucial:
      * **Desacoplamento:** A vida do Portainer não está atrelada a um `docker-compose.yaml` específico. Seus dados e sua rede persistem independentemente do ciclo de vida do contêiner.
      * **Gestão Centralizada:** Permite que outros serviços, como o Traefik, se comuniquem com ele na mesma rede compartilhada.
3. **Setup Idempotente:** O comando `make setup` é inteligente. Ele verifica se a rede e o volume necessários já existem antes de tentar criá-los. Você pode rodá-lo quantas vezes quiser, e ele apenas garantirá que o ambiente esteja no estado correto, sem causar erros.
4. **Persistência de Dados:** Todos os dados de configuração do Portainer (usuários, endpoints, etc.) são armazenados no volume Docker, garantindo que nada seja perdido ao reiniciar ou recriar o contêiner.

## ✅ Pré-requisitos

Antes de começar, garanta que o ambiente atenda aos seguintes requisitos:

* **Docker Engine** e **Docker Compose**
* Um shell compatível com `bash` (Linux, macOS, WSL2/Git Bash).
* **Uma instância do Traefik** já rodando e conectada à mesma rede externa (`web`, por padrão). Este projeto depende do Traefik para exposição web.
* **Acesso ao Socket do Docker:** O usuário que executa os comandos precisa ter permissão para acessar `/var/run/docker.sock`.

## 🚀 Configuração e Deploy

O processo foi desenhado para ser rápido e livre de ambiguidades.

### 1\. Clone o Repositório

```bash
# Navegue até seu diretório de projetos (ex: /srv/docker)
cd /srv/docker

git clone https://github.com/RafaelQSantos-RQS/portainer-server
cd portainer-server
```

### 2\. Prepare os Arquivos de Configuração

O `Makefile` irá criar o arquivo de ambiente para você, mas ele precisa da sua intervenção.

```bash
make setup
```

Este comando irá detectar que o arquivo `.env` não existe, criá-lo a partir do `env.template` e pedir para que você o edite. Ele também garantirá que a rede e o volume Docker estejam prontos.

### 3\. Configure as Variáveis de Ambiente

Abra o arquivo `.env` que foi criado e ajuste as variáveis:

* `EXTERNAL_NETWORK_NAME`: Deve ser a mesma rede usada pelo seu Traefik (geralmente `web`).
* `SERVER_DATA_VOLUME_NAME`: O nome do volume para persistir os dados. O padrão é seguro.
* `PORTAINER_COMMUNITY_VERSION`: Fixe uma versão estável. Não use `latest` em produção.
* `DOMAIN`: O subdomínio pelo qual você acessará o Portainer (ex: `portainer.meudominio.com`). Este domínio deve apontar para o IP do seu servidor onde o Traefik está rodando.

### 4\. Inicie o Serviço

Após salvar o `.env`, suba a stack:

```bash
make up
```

O Portainer será iniciado e o Traefik o detectará automaticamente. Acesse o domínio que você configurou no passo anterior para completar a configuração inicial do Portainer (criação do usuário administrador).

## 🧰 Uso e Manutenção (Comandos do Makefile)

Toda a interação com o projeto é feita pela interface padronizada do `Makefile`.

```bash
# Mostra todos os comandos disponíveis
make help

# Prepara o ambiente (rede, volume, .env)
make setup

# Sobe o contêiner em background
make up

# Para e remove o contêiner
make down

# Reinicia o serviço
make restart

# Acompanha os logs em tempo real
make logs

# Verifica o status do contêiner
make status

# Baixa a imagem mais recente definida no .env
make pull
```

### Comando de Sincronização

O `Makefile` inclui um comando `sync`.

```bash
# ATENÇÃO: Descarta todas as alterações locais e sincroniza com a branch 'main' remota
make sync
```

**⚠️ Aviso:** Use o comando `sync` com extrema cautela. Ele foi projetado para ambientes onde o repositório é a única fonte da verdade e as instâncias locais devem apenas espelhar o estado remoto. Ele irá apagar permanentemente quaisquer alterações locais que você tenha feito.

## 💬 Contato e Contribuições

Este projeto é mantido como parte do meu portfólio pessoal e como um exercício prático de boas práticas de implantação.

Se você encontrar algum problema, tiver sugestões de melhoria ou quiser discutir alguma das decisões de arquitetura adotadas aqui, sinta-se à vontade para abrir uma **Issue** neste repositório do GitHub.

Para outros assuntos, você pode me encontrar no [LinkedIn](https://www.linkedin.com/in/rafael-queiroz-santos). O feedback construtivo é sempre bem-vindo.
