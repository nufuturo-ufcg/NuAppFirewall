# Leitura de Regras de Bloqueio

## Contexto
O NuAppFirewall é uma aplicação de segurança projetada para filtrar o fluxo de rede, atuando como um firewall. Por meio de regras definidas em um arquivo JSON, o NuAppFirewall permite ou bloqueia conexões de rede.

Inicialmente, a aplicação foi desenvolvida apenas para regras do tipo allow, por questão de simplicidade de implementação. Com o avanço do desenvolvimento, o arquivo de regras foi adaptado para conter tanto regras do tipo allow quanto do tipo block. O código foi ajustado para lidar com esse novo formato, implementando uma lógica em que regras block possuem prioridade sobre regras allow.

## Decisão
Foi decidido que, na implementação do código, regras do tipo block possuem prioridade absoluta no sistema, ou seja, ao avaliar as regras, sempre que uma regra block for encontrada, ela será aplicada, ignorando regras do tipo allow que possam existir para esse mesmo destino. Essa decisão é importante pois mesmo em cenários de regras conflitantes, teremos a garantia de que bloqueios críticos serão respeitados.

No código, essa decisão resultou na alteração de métodos do RulesManager. A busca por regras agora ocorre em duas etapas: por questões de eficiência, primeiramente o sistema realiza a busca por uma regra específica diretamente no dicionário rules, utilizando como chave o caminho exato da aplicação. Em seguida, se nenhuma regra for encontrada, ou não atender a preferência por regras de bloqueio (quando habilitada), então é feita uma busca de regras por substring (getRuleBySubstring).

Esse método percorre todas as regras disponíveis, verificando se o caminho da aplicação contém qualquer um dos caminhos definidos como substring. Durante a busca por substring, as regras encontradas são classificadas: regras do tipo block são imediatamente retornadas para que sejam aplicadas, enquanto regras do tipo allow são armazenadas como alternativa caso nenhuma regra de bloqueio esteja presente.

## Alternativas consideradas
* **Buscar regras apenas com getRuleBySubstring:** Essa alternativa foi descartada devido ao alto custo de desempenho. Embora esse método consiga encontrar uma regra por meio do caminho completo da aplicação, ele é mais custoso do que consultar diretamente o dicionário de regras. Portanto, por questões de eficiência, foi decidido priorizar a consulta direta ao dicionário de regras e posteriormente, apenas caso necessário, utilizar a busca por substring.

## Consequências
* **Melhor desempenho:** Consultar o dicionário de regras diretamente é muito mais rápido do que realizar buscas por substring. Isso reduz o tempo de processamento e melhora a eficiência da aplicação.
* **Facilidade de manutenção:** A estrutura segmentada - primeiro consulta ao dicionário, depois busca por substring - facilita a realização de possíveis ajustes e a depuração do sistema, já que cada etapa do processo está bem delimitada.
