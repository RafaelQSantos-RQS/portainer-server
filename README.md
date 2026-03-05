# Portainer Server: Gestão de Contêineres como Serviço

<!-- markdownlint-disable-next-line MD033 -->
<p align="center"><img src="https://github.com/portainer/portainer/blob/develop/app/assets/images/portainer-github-banner.png?raw=true" alt="Portainer Banner" title="portainer"></p>

## 🎯 Visão Geral

Este projeto implanta uma instância do **Portainer Community Edition** de forma robusta e padronizada, projetada para se integrar a uma infraestrutura on-premise que já utiliza o Traefik como proxy reverso.

O Portainer servirá como nossa interface gráfica de gerenciamento (GUI) para o ambiente Docker, oferecendo uma visão clara e controle sobre contêineres, volumes, redes e outros recursos. A implantação é gerenciada por um `Makefile`, garantindo que o setup e a manutenção sejam processos simples e à prova de erros.

## 🏗️ Arquitetura e Decisões de Design

A estabilidade vem de um design deliberado. Este serviço não é uma ilha; ele foi projetado para ser um cidadão de primeira classe na nossa infraestrutura conteinerizada.

### Modos de Implantação

Este projeto suporta dois modos de implantação:

1. **Docker Compose** (`docker-compose.yaml`): Ideal para ambientes de desenvolvimento ou pequenos deployments.
2. **Docker Swarm** (`docker-stack.yml`): Ideal para ambientes de produção com alta disponibilidade e cluster.

### Decisões de Design

1. **Integração com o Proxy Reverso (Traefik):** Os arquivos de configuração já vêm com as *labels* necessárias para que o Traefik descubra, exponha e proteja o Portainer automaticamente via HTTPS. Não há exposição de portas diretas no host; o acesso é centralizado na portaria.
2. **Rede e Volume Externos:** O serviço se conecta a uma rede Docker externa (padrão: `web`) e utiliza um volume Docker externo (padrão: `portainer-server-data`). Isso é crucial:
   - **Desacoplamento:** A vida do Portainer não está atrelada a um arquivo de composição específico. Seus dados e sua rede persistem independentemente do ciclo de vida do contêiner.
   - **Gestão Centralizada:** Permite que outros serviços, como o Traefik, se comuniquem com ele na mesma rede compartilhada.
3. **Setup Idempotente:** O comando `make setup` é inteligente. Ele verifica se a rede e o volume necessários já existem antes de tentar criá-los. Você pode rodá-lo quantas vezes quiser, e ele apenas garantirá que o ambiente esteja no estado correto, sem causar erros.
4. **Persistência de Dados:** Todos os dados de configuração do Portainer (usuários, endpoints, etc.) são armazenados no volume Docker, garantindo que nadaiciar ou recriar o contêiner seja perdido ao rein.

### Arquitetura Docker Swarm

No modo Swarm, o projeto utiliza uma arquitetura distribuída:

- **Portainer Server**: O serviço principal que fornece a interface web.
- **Portainer Agent**: Um agente que roda em modo global em todos os nós do cluster, permitindo que o Portainer gerencie o cluster inteiro a partir de um único ponto.

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Swarm                            │
│                                                             │
│  ┌─────────────────┐         ┌─────────────────┐          │
│  │   Manager Node  │         │   Worker Node   │          │
│  │                 │         │                 │          │
│  │  ┌───────────┐  │         │  ┌───────────┐  │          │
│  │  │  Server   │  │◄────────┼──│  Agent    │  │          │
│  │  │ (replica) │  │         │  │ (global)  │  │          │
│  │  └───────────┘  │         │  └───────────┘  │          │
│  │                 │         │                 │          │
│  └─────────────────┘         └─────────────────┘          │
│         │                                                   │
│         │                                                   │
│  ┌──────┴──────┐                                           │
│  │  Traefik    │  (external)                               │
│  │  (web)      │                                           │
│  └─────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

## ✅ Pré-requisitos

Antes de começar, garanta que o ambiente atenda aos seguintes requisitos:

### Para Docker Compose

- **Docker Engine** e **Docker Compose** instalados
- Um shell compatível com `bash` (Linux, macOS, WSL2/Git Bash).
- **Uma instância do Traefik** já rodando e conectada à mesma rede externa (`web`, por padrão). Este projeto depende do Traefik para exposição web.
- **Acesso ao Socket do Docker:** O usuário que executa os comandos precisa ter permissão para acessar `/var/run/docker.sock`.

### Para Docker Swarm

- **Docker Swarm** inicializado (`docker swarm init`)
- **Uma instância do Traefik** já rodando em modo Swarm e conectada à rede `swarm-net` (definida no `docker-stack.yml`).
- Recomendado: pelo menos 1 nó manager e 1 nó worker.

## 🚀 Configuração e Deploy

O processo foi desenhado para ser rápido e livre de ambiguidades.

### 1. Clone o Repositório

```bash
# Navegue até seu diretório de projetos
cd /srv/docker

git clone https://github.com/RafaelQSantos-RQS/portainer-server
cd portainer-server
```

### 2. Prepare os Arquivos de Configuração

O `Makefile` irá criar o arquivo de ambiente para você, mas ele precisa da sua intervenção.

```bash
make setup
```

Este comando irá detectar que o arquivo `.env` não existe, criá-lo a partir do `env.template` e pedir para que você o edite. Ele também garantirá que a rede e o volume Docker estejam prontos.

### 3. Configure as Variáveis de Ambiente

Abra o arquivo `.env` que foi criado e ajuste as variáveis:

#### Variáveis Obrigatórias

- `DOMAIN`: O subdomínio pelo qual você acessará o Portainer (ex: `portainer.meudominio.com`). Este domínio deve apontar para o IP do seu servidor onde o Traefik está rodando.

#### Variáveis Opcionais (Docker Compose)

- `EXTERNAL_NETWORK_NAME`: Deve ser a mesma rede usada pelo seu Traefik (geralmente `web`). Padrão: `web`.
- `SERVER_DATA_VOLUME_NAME`: O nome do volume para persistir os dados. Padrão: `portainer-server-data`.
- `PORTAINER_COMMUNITY_VERSION`: Fixe uma versão estável. Não use `latest` em produção. Ex: `2.21.4`.

#### Variáveis Opcionais (Docker Swarm)

- `PORTAINER_AGENT_VERSION`: Versão do agente Portainer. Padrão: `lts`.
- `PORTAINER_COMMUNITY_VERSION`: Versão do Portainer Server. Padrão: `lts`.
- `SERVER_DATA_VOLUME_NAME`: Nome do volume para dados ( Swarm). Padrão: `portainer_server_swarm_data`.

### 4. Inicie o Serviço

#### Docker Compose

```bash
make compose-up
```

#### Docker Swarm

```bash
make swarm-deploy
```

O Portainer será iniciado e o Traefik o detectará automaticamente. Acesse o domínio que você configurou no passo anterior para completar a configuração inicial do Portainer (criação do usuário administrador).

## 🧰 Uso e Manutenção (Comandos do Makefile)

Toda a interação com o projeto é feita pela interface padronizada do `Makefile`.

### Comandos Gerais

```bash
# Mostra todos os comandos disponíveis
make help

# Prepara o ambiente (rede, volume, .env)
make setup

# Valida a configuração do Docker Compose
make validate

# ATENÇÃO: Descarta todas as alterações locais e sincroniza com a branch 'main' remota
make sync
```

**⚠️ Aviso:** Use o comando `sync` com extrema cautela. Ele foi projetado para ambientes onde o repositório é a única fonte da verdade e as instâncias locais devem apenas espelhar o estado remoto. Ele irá apagar permanentemente quaisquer alterações locais que você tenha feito.

### Comandos Docker Compose

```bash
# Sobe os contêineres em background
make compose-up

# Para e remove os contêineres
make compose-down

# Reinicia os contêineres
make compose-restart

# Acompanha os logs em tempo real
make compose-logs

# Verifica o status dos contêineres
make compose-status

# Baixa a imagem mais recente definida no .env
make compose-pull
```

### Comandos Docker Swarm

```bash
# Faz deploy do Portainer no Swarm
make swarm-deploy

# Remove o Portainer do Swarm
make swarm-remove

# Verifica o status do stack
make swarm-status

# Acompanha os logs do Swarm em tempo real
make swarm-logs
```

## 📂 Estrutura do Projeto

```
portainer-server/
├── .env                   # Variáveis de ambiente (gerado automaticamente)
├── .env.template          # Template de variáveis de ambiente
├── Makefile               # Automação de tarefas
├── docker-compose.yaml    # Configuração para Docker Compose
├── docker-stack.yml       # Configuração para Docker Swarm
└── README.md              # Este arquivo
```

## 🔧 Variáveis de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `DOMAIN` | Domínio para acesso ao Portainer | `portainer.example` |
| `EXTERNAL_NETWORK_NAME` | Nome da rede externa (Compose) | `web` |
| `SERVER_DATA_VOLUME_NAME` | Nome do volume de dados | `portainer-server-data` |
| `PORTAINER_COMMUNITY_VERSION` | Versão do Portainer CE | `lts` |
| `PORTAINER_AGENT_VERSION` | Versão do Agent (Swarm) | `lts` |

## 🔨 Solução de Problemas

### Não consigo acessar o Portainer

1. Verifique se o Traefik está rodando: `docker ps` (Compose) ou `make swarm-status` (Swarm)
2. Verifique os logs do Traefik para erros de roteamento
3. Confirme que o domínio está apontando para o IP correto
4. Verifique se o certificado TLS está configurado no Traefik

### Os dados não persistem

1. Verifique se o volume Docker existe: `docker volume ls`
2. No Swarm, o volume é criado automaticamente pelo stack e não é removido com `docker stack rm`

### Erro ao fazer deploy no Swarm

1. Verifique se o Swarm está inicializado: `docker info | grep Swarm`
2. Confirme que a rede `swarm-net` existe: `docker network ls`
3. Verifique se o Traefik está configurado para o modo Swarm

## 📝 Licença

Este projeto está licenciado sob os termos do arquivo [LICENSE](LICENSE).

## 💬 Contato e Contribuições

Este projeto é mantido como parte do meu portfólio pessoal e como um exercício prático de boas práticas de implantação.

Se você encontrar algum problema, tiver sugestões de melhoria ou quiser discutir alguma das decisões de arquitetura adotadas aqui, sinta-se à vontade para abrir uma **Issue** neste repositório do GitHub.

Para outros assuntos, você pode me encontrar no [LinkedIn](https://www.linkedin.com/in/rafael-queiroz-santos). O feedback construtivo é sempre bem-vindo.
