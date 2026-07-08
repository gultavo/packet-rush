/// Dados didáticos de cada fase: texto de leitura e perguntas do quiz.
///
/// Os dados foram extraídos do documento PACKET~1.MD e mapeados para as
/// 27 fases do jogo (5 mundos / andares).

class Pergunta {
  final String enunciado;
  final List<String> alternativas; // sempre 4
  final int correta; // índice 0–3

  const Pergunta({
    required this.enunciado,
    required this.alternativas,
    required this.correta,
  });
}

class FaseContent {
  final String titulo;
  final String conteudo;
  final List<Pergunta> perguntas; // sempre 5

  const FaseContent({
    required this.titulo,
    required this.conteudo,
    required this.perguntas,
  });
}

/// Chave: "andar_fase" (ex: "1_1", "3_6").
final Map<String, FaseContent> faseContents = {
  // =====================================================================
  // MUNDO 1 — CAMADA FÍSICA
  // =====================================================================

  '1_1': const FaseContent(
    titulo: 'O Subsolo dos Sinais',
    conteudo:
        'Toda comunicação em rede começa com um problema simples: como transformar informação em algo que viaje por um fio, uma fibra ou o ar? A resposta é o bit, a menor unidade de informação possível, representada como 0 ou 1. A Camada Física é a responsável por converter sequências de bits em sinais físicos: pulsos de tensão elétrica (cabos de cobre), pulsos de luz (fibra óptica) ou ondas eletromagnéticas (Wi-Fi, rádio, satélite).\n\n'
        'Essa camada define características muito concretas: os níveis de voltagem que representam um 0 ou um 1, o formato dos conectores (como o RJ-45), o tempo de duração de cada bit e a taxa de transmissão (medida em bits por segundo, ou bps). Repare que a Camada Física não sabe o que os bits significam — ela não lê endereços, não corrige erros de conteúdo e não entende "mensagens". Ela apenas garante que um bit enviado de um lado chegue, fisicamente, ao outro. Interpretar esses bits como quadros, pacotes ou mensagens é trabalho das camadas acima.\n\n'
        'Por isso, dizemos que a Camada Física trata de hardware e sinal bruto: cabos, conectores, antenas, tensão, frequência e luz. É o alicerce sobre o qual todo o resto do modelo TCP/IP é construído.',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a menor unidade de informação tratada pela Camada Física?',
        alternativas: ['O pacote', 'O bit', 'O quadro (frame)', 'O segmento'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'A Camada Física converte bits em sinais físicos. Quais exemplos de sinais são citados no texto?',
        alternativas: [
          'Pulsos de tensão elétrica, pulsos de luz e ondas eletromagnéticas',
          'Apenas sinais sonoros',
          'Apenas sinais elétricos',
          'Códigos binários impressos em papel',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que a Camada Física define?',
        alternativas: [
          'Endereços IP de origem e destino',
          'Níveis de voltagem, formato de conectores, duração dos bits e taxa de transmissão',
          'O conteúdo das mensagens trocadas',
          'As regras de roteamento entre redes',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que o texto afirma que a Camada Física NÃO faz?',
        alternativas: [
          'Não transmite bits',
          'Não usa conectores físicos',
          'Não lê endereços nem entende o significado das mensagens',
          'Não converte bits em sinais',
        ],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'Como o texto descreve a taxa de transmissão de bits?',
        alternativas: [
          'Em metros por segundo',
          'Em bits por segundo (bps)',
          'Em pacotes por minuto',
          'Em hertz de cor',
        ],
        correta: 1,
      ),
    ],
  ),

  '1_2': const FaseContent(
    titulo: 'A Oficina dos Meios',
    conteudo:
        'Se a Camada Física transporta sinais, ela precisa de um meio de transmissão por onde esses sinais viajam. Esses meios se dividem em duas famílias.\n\n'
        'Os meios guiados conduzem o sinal por um caminho físico definido: o par trançado (cabos UTP/STP, usados em redes Ethernet domésticas e corporativas, baratos mas sensíveis a interferência eletromagnética); o cabo coaxial (mais blindado que o par trançado, historicamente usado em redes antigas e TV a cabo); e a fibra óptica (transmite pulsos de luz em vez de eletricidade, oferece altíssima velocidade e alcance, é imune a interferência eletromagnética, mas tem custo de instalação mais alto).\n\n'
        'Já os meios não guiados transmitem o sinal pelo ar, sem um caminho físico fixo: ondas de rádio (Wi-Fi, redes celulares), micro-ondas (enlaces ponto a ponto e satélites) e infravermelho (comunicação de curtíssima distância, como controles remotos). Meios não guiados oferecem mobilidade, mas são mais expostos a interferência e a riscos de segurança, já que o sinal se propaga em todas as direções e pode ser capturado por qualquer receptor no alcance.\n\n'
        'A escolha do meio depende do equilíbrio entre custo, distância, velocidade necessária e exposição a interferências — não existe um meio "melhor" em termos absolutos, apenas mais adequado para cada cenário.',
    perguntas: [
      Pergunta(
        enunciado: 'Quais são as duas grandes famílias de meios de transmissão citadas no texto?',
        alternativas: ['Guiados e não guiados', 'Digitais e analógicos', 'Rápidos e lentos', 'Públicos e privados'],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, qual meio guiado é imune a interferência eletromagnética e oferece altíssima velocidade?',
        alternativas: ['Par trançado', 'Cabo coaxial', 'Fibra óptica', 'Wi-Fi'],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'Qual meio é descrito como o mais usado em redes Ethernet domésticas, porém sensível a interferência?',
        alternativas: ['Fibra óptica', 'Par trançado', 'Micro-ondas', 'Infravermelho'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O texto cita três exemplos de meios não guiados. Quais são eles?',
        alternativas: [
          'Par trançado, coaxial e fibra',
          'Rádio, micro-ondas e infravermelho',
          'UTP, STP e coaxial',
          'Satélite, cobre e vidro',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que o texto diz que meios não guiados são mais expostos a riscos de segurança?',
        alternativas: [
          'Porque usam cabos muito longos',
          'Porque o sinal se propaga em todas as direções e pode ser capturado por qualquer receptor no alcance',
          'Porque não podem ser criptografados',
          'Porque só funcionam em curtas distâncias',
        ],
        correta: 1,
      ),
    ],
  ),

  '1_3': const FaseContent(
    titulo: 'Interferência na Linha',
    conteudo:
        'Nenhum sinal viaja em um mundo perfeito. Ao longo do percurso, ele sofre degradações que a Camada Física precisa conhecer para ser projetada corretamente.\n\n'
        'A atenuação é a perda de força do sinal conforme ele percorre distância — por isso cabos e enlaces têm um alcance máximo recomendado antes que o sinal fique fraco demais para ser interpretado corretamente. O ruído é qualquer sinal indesejado que se mistura ao sinal original, podendo vir de motores elétricos, outros cabos próximos ou fontes de energia. Quando esse ruído vem de um cabo vizinho "vazando" sinal para o cabo ao lado, chamamos de interferência eletromagnética (crosstalk) — um problema clássico em cabos de par trançado mal instalados. Há ainda a distorção, quando diferentes componentes do sinal chegam ao destino em momentos ligeiramente diferentes, embaralhando a forma original da onda.\n\n'
        'Para medir o quão "limpo" está um sinal em relação ao ruído, usa-se a relação sinal-ruído (SNR): quanto maior essa relação, mais fácil é para o receptor distinguir o sinal do ruído de fundo. Diversas técnicas mitigam esses problemas: blindagem (cabos STP, blindagem de fibra), repetidores que regeneram o sinal periodicamente ao longo de distâncias longas, e o próprio uso de fibra óptica, que por natureza é imune a interferência eletromagnética.',
    perguntas: [
      Pergunta(
        enunciado: 'Como o texto define "atenuação"?',
        alternativas: [
          'Excesso de velocidade no cabo',
          'Perda de força do sinal conforme percorre distância',
          'Aumento de temperatura no conector',
          'Duplicação do sinal original',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que é "crosstalk", segundo o texto?',
        alternativas: [
          'Um tipo de conector',
          'Ruído que vem de um cabo vizinho vazando sinal para o cabo ao lado',
          'Uma técnica de criptografia',
          'Um protocolo de roteamento',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que representa a relação sinal-ruído (SNR)?',
        alternativas: [
          'O tamanho físico do cabo',
          'O quão fácil é para o receptor distinguir o sinal do ruído de fundo',
          'A quantidade de dispositivos conectados',
          'O tempo de vida útil do cabo',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais soluções o texto cita para mitigar ruído e interferência?',
        alternativas: [
          'Blindagem, repetidores e uso de fibra óptica',
          'Aumentar apenas a voltagem do sinal',
          'Trocar o endereço IP do dispositivo',
          'Reduzir o número de bits enviados',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que acontece quando diferentes componentes do sinal chegam ao destino em momentos ligeiramente diferentes?',
        alternativas: ['Atenuação', 'Crosstalk', 'Distorção', 'Aumento do SNR'],
        correta: 2,
      ),
    ],
  ),

  '1_4': const FaseContent(
    titulo: 'O Corredor Binário',
    conteudo:
        'Depois de entender os meios e os problemas de sinal, falta responder: como exatamente um 0 ou 1 é representado fisicamente? Isso é papel da codificação de linha. Em uma técnica simples chamada NRZ (Non-Return-to-Zero), um nível alto de tensão representa 1 e um nível baixo representa 0. O problema é que sequências longas do mesmo bit dificultam a sincronização entre emissor e receptor. Por isso, técnicas como a codificação Manchester intercalam uma transição de nível no meio de cada bit, garantindo que emissor e receptor nunca percam a sincronia, ao custo de exigir o dobro da taxa de sinalização.\n\n'
        'É importante não confundir dois conceitos: a taxa de bits (bit rate), medida em bits por segundo, indica quantos bits são transmitidos por segundo; já a taxa de baud (baud rate) indica quantas mudanças de sinal (símbolos) ocorrem por segundo. Em codificações simples, um símbolo carrega um bit, e as duas taxas coincidem — mas em técnicas mais avançadas, um único símbolo pode carregar vários bits, fazendo o bit rate superar o baud rate.\n\n'
        'Quando um sinal digital precisa trafegar por um meio pensado para sinal analógico (como uma linha telefônica antiga), entra em cena a modulação: um modem (modulador/demodulador) converte bits em variações de amplitude, frequência ou fase de uma onda portadora (AM, FM, PM) e faz o processo inverso do outro lado. Por fim, quando vários sinais precisam dividir o mesmo meio físico, usa-se multiplexação: por tempo (TDM) ou por frequência (FDM).',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a vantagem da codificação Manchester sobre a NRZ, segundo o texto?',
        alternativas: [
          'Ela usa menos energia',
          'Ela garante sincronização entre emissor e receptor com uma transição no meio de cada bit',
          'Ela elimina a necessidade de conectores',
          'Ela dobra o alcance do cabo',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual a diferença entre bit rate e baud rate, conforme descrito no texto?',
        alternativas: [
          'São exatamente a mesma coisa em qualquer codificação',
          'Bit rate mede bits por segundo; baud rate mede mudanças de sinal (símbolos) por segundo',
          'Bit rate mede distância; baud rate mede voltagem',
          'Baud rate só existe em fibra óptica',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a função de um modem, segundo o texto?',
        alternativas: [
          'Amplificar apenas sinais de fibra óptica',
          'Converter bits em variações de amplitude, frequência ou fase de uma onda portadora, e vice-versa',
          'Detectar erros em pacotes IP',
          'Atribuir endereços MAC aos dispositivos',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que é multiplexação por tempo (TDM), de acordo com o texto?',
        alternativas: [
          'Cada sinal usa uma faixa de frequência diferente',
          'Cada sinal usa o meio físico em um instante diferente',
          'Um único sinal ocupa o meio para sempre',
          'A divisão de um pacote em múltiplos segmentos',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que sequências longas do mesmo bit são um problema na codificação NRZ?',
        alternativas: [
          'Porque aumentam o custo do cabo',
          'Porque dificultam a sincronização entre emissor e receptor',
          'Porque geram crosstalk automaticamente',
          'Porque exigem fibra óptica',
        ],
        correta: 1,
      ),
    ],
  ),

  '1_5': const FaseContent(
    titulo: 'O Gerador Central',
    conteudo:
        'Fechando o Mundo 1, é hora de conhecer os dispositivos físicos que operam exclusivamente na Camada Física e revisar os conceitos que sustentam toda a rede.\n\n'
        'O repetidor é o dispositivo mais simples: ele recebe um sinal enfraquecido, regenera sua forma original e o retransmite, estendendo o alcance de um cabo ou enlace sem entender nada do conteúdo transmitido. O hub é essencialmente um repetidor com múltiplas portas: tudo que chega em uma porta é regenerado e retransmitido para todas as outras portas, sem qualquer inteligência sobre quem deveria receber o quê. Isso significa que todos os dispositivos ligados a um hub compartilham o mesmo domínio de colisão — só um pode transmitir por vez sem gerar conflito, o que limita bastante o desempenho em redes maiores (por isso hubs foram amplamente substituídos por switches).\n\n'
        'Três conceitos de desempenho merecem destaque: largura de banda (bandwidth) é a capacidade máxima teórica de um enlace; throughput é a taxa real de dados efetivamente entregues, quase sempre menor que a largura de banda; e latência é o tempo que um bit leva para percorrer o caminho entre origem e destino.',
    perguntas: [
      Pergunta(
        enunciado: 'O que faz um repetidor, segundo o texto?',
        alternativas: [
          'Filtra pacotes indesejados',
          'Recebe um sinal enfraquecido, regenera sua forma original e o retransmite',
          'Atribui endereços IP',
          'Criptografa os dados transmitidos',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que todos os dispositivos ligados a um hub compartilham o mesmo domínio de colisão?',
        alternativas: [
          'Porque o hub retransmite tudo que chega para todas as outras portas, sem inteligência sobre o destino',
          'Porque o hub criptografa o tráfego',
          'Porque o hub usa apenas fibra óptica',
          'Porque o hub atribui um endereço MAC único a cada porta',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Qual é a diferença entre largura de banda e throughput, segundo o texto?',
        alternativas: [
          'São sinônimos exatos',
          'Largura de banda é a capacidade máxima teórica; throughput é a taxa real de dados efetivamente entregues',
          'Largura de banda mede latência; throughput mede distância',
          'Throughput é sempre maior que a largura de banda',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que é latência, de acordo com o texto?',
        alternativas: [
          'A capacidade máxima de um cabo',
          'O tempo que um bit leva para percorrer o caminho entre origem e destino',
          'O número de dispositivos conectados a um hub',
          'A quantidade de ruído em um sinal',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, por que hubs foram amplamente substituídos por switches?',
        alternativas: [
          'Porque hubs limitam o desempenho ao colocar todos os dispositivos no mesmo domínio de colisão',
          'Porque hubs não conseguem transmitir sinais elétricos',
          'Porque hubs só funcionam com fibra óptica',
          'Porque switches são dispositivos de Camada Física mais baratos',
        ],
        correta: 0,
      ),
    ],
  ),

  // =====================================================================
  // MUNDO 2 — CAMADA DE ENLACE
  // =====================================================================

  '2_1': const FaseContent(
    titulo: 'O Salão dos Quadros',
    conteudo:
        'Enquanto a Camada Física só enxerga bits soltos, a Camada de Enlace organiza esses bits em blocos com começo, meio e fim bem definidos: os quadros (frames). Um quadro tem cabeçalho (endereço de origem, endereço de destino, tipo de dado) e, normalmente, um campo final de verificação de erros.\n\n'
        'A Camada de Enlace tem três funções centrais. A primeira é o enquadramento (framing): delimitar onde um quadro começa e termina dentro do fluxo de bits. A segunda é a endereçamento físico: cada interface de rede recebe um endereço MAC, usado para identificar dispositivos dentro da mesma rede local — diferente do endereço IP (da Camada de Rede), que identifica redes inteiras. A terceira é a detecção de erros: verificar se o quadro chegou intacto.\n\n'
        'Essa camada também é responsável por controlar o acesso ao meio físico quando ele é compartilhado por vários dispositivos e por oferecer, em alguns casos, um controle de fluxo básico entre dispositivos vizinhos. É importante perceber a lógica do modelo em camadas: a Camada de Enlace recebe um pacote vindo da Camada de Rede, o encapsula dentro de um quadro e entrega esse quadro à Camada Física para ser transformado em sinais.',
    perguntas: [
      Pergunta(
        enunciado: 'Como se chama a unidade de dados organizada pela Camada de Enlace?',
        alternativas: ['Pacote', 'Segmento', 'Quadro (frame)', 'Bit'],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'Quais são as três funções centrais da Camada de Enlace citadas no texto?',
        alternativas: [
          'Roteamento, DNS e criptografia',
          'Enquadramento, endereçamento físico (MAC) e detecção de erros',
          'Modulação, multiplexação e atenuação',
          'Handshake, controle de fluxo e portas',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a diferença entre endereço MAC e endereço IP, segundo o texto?',
        alternativas: [
          'MAC identifica dispositivos na rede local; IP identifica redes inteiras',
          'MAC e IP são a mesma coisa',
          'MAC é usado apenas em fibra óptica',
          'IP é definido pela Camada Física',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que significa "enquadramento (framing)"?',
        alternativas: [
          'Criptografar o conteúdo do quadro',
          'Delimitar onde um quadro começa e termina dentro do fluxo de bits',
          'Escolher a melhor rota entre redes',
          'Definir a voltagem do sinal elétrico',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que a Camada de Enlace faz com um pacote recebido da Camada de Rede?',
        alternativas: [
          'Descarta o pacote automaticamente',
          'Encapsula o pacote dentro de um quadro e entrega à Camada Física',
          'Converte o pacote diretamente em um endereço IP',
          'Envia o pacote direto para a Camada de Aplicação',
        ],
        correta: 1,
      ),
    ],
  ),

  '2_2': const FaseContent(
    titulo: 'O Grande Switch',
    conteudo:
        'O switch é o principal dispositivo da Camada de Enlace e o sucessor natural do hub. Diferente do hub, que retransmite tudo para todas as portas, o switch é inteligente: ele constrói e mantém uma tabela de endereços MAC (também chamada tabela CAM), associando cada endereço MAC ao número da porta onde aquele dispositivo foi visto pela última vez.\n\n'
        'O funcionamento segue três verbos: aprender, encaminhar e filtrar. Ao receber um quadro, o switch aprende o MAC de origem e a porta correspondente. Em seguida, consulta o MAC de destino: se souber em qual porta esse destino está, encaminha o quadro só para aquela porta específica; se ainda não conhecer o destino, ele "inunda" (flood) o quadro para todas as portas, exceto a de origem.\n\n'
        'Essa inteligência muda completamente o desempenho da rede: cada porta de um switch é seu próprio domínio de colisão, permitindo comunicação full-duplex sem risco de colisão entre dispositivos ligados a portas diferentes. Ainda assim, todas as portas de um switch continuam fazendo parte do mesmo domínio de broadcast.',
    perguntas: [
      Pergunta(
        enunciado: 'O que o switch constrói e mantém para tomar decisões de encaminhamento?',
        alternativas: [
          'Uma tabela de rotas IP',
          'Uma tabela de endereços MAC (tabela CAM)',
          'Uma tabela de portas TCP',
          'Um registro de nomes DNS',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que o switch faz quando ainda não conhece a porta do MAC de destino?',
        alternativas: [
          'Descarta o quadro',
          'Envia o quadro apenas para a porta de origem',
          'Inunda (flood) o quadro para todas as portas, exceto a de origem',
          'Aguarda indefinidamente sem enviar',
        ],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'Por que cada porta de um switch é considerada seu próprio domínio de colisão?',
        alternativas: [
          'Porque o switch encaminha quadros de forma seletiva por porta, permitindo full-duplex sem colisão entre portas diferentes',
          'Porque cada porta usa um protocolo diferente',
          'Porque o switch não tem tabela MAC',
          'Porque cada porta tem seu próprio endereço IP',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que ainda é compartilhado entre todas as portas de um switch?',
        alternativas: ['O domínio de broadcast', 'O domínio de erro', 'A tabela de rotas', 'O endereço IP'],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Quais são os três verbos que descrevem o funcionamento do switch, segundo o texto?',
        alternativas: [
          'Modular, atenuar e amplificar',
          'Aprender, encaminhar e filtrar',
          'Rotear, sub-rotear e encapsular',
          'Criptografar, autenticar e validar',
        ],
        correta: 1,
      ),
    ],
  ),

  '2_3': const FaseContent(
    titulo: 'Frames Corrompidos',
    conteudo:
        'Mesmo com toda a organização em quadros, ruído e interferência da Camada Física podem corromper bits durante a transmissão. A Camada de Enlace precisa detectar esses erros antes de repassar o quadro adiante.\n\n'
        'A técnica mais simples é o bit de paridade: adiciona-se um bit extra que indica se o número de bits "1" no dado é par ou ímpar. É simples, mas falha quando dois bits são corrompidos ao mesmo tempo. Uma técnica mais robusta é o checksum, que soma os valores dos dados e envia esse resultado junto.\n\n'
        'A técnica mais usada em redes reais é o CRC (Cyclic Redundancy Check): o emissor trata os dados como um grande número binário, faz uma divisão matemática por um valor fixo e anexa o resto dessa divisão ao quadro, no campo chamado FCS (Frame Check Sequence). O receptor repete a mesma divisão; se o resultado não bater, o quadro é considerado corrompido e simplesmente descartado.\n\n'
        'É essencial entender: a Camada de Enlace tipicamente detecta erros, mas não os corrige nem retransmite automaticamente — quando um quadro é descartado, cabe a camadas superiores (como TCP) solicitar uma nova transmissão.',
    perguntas: [
      Pergunta(
        enunciado: 'O que faz a técnica do bit de paridade?',
        alternativas: [
          'Criptografa o quadro inteiro',
          'Adiciona um bit extra que indica se o número de bits "1" é par ou ímpar',
          'Define o endereço MAC do dispositivo',
          'Multiplexa o sinal em várias frequências',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Como funciona o CRC (Cyclic Redundancy Check), segundo o texto?',
        alternativas: [
          'Soma simples dos bits sem nenhuma divisão',
          'Divisão matemática dos dados por um valor fixo, anexando o resto ao quadro no campo FCS',
          'Criptografia assimétrica dos dados',
          'Verificação apenas do endereço de destino',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que acontece quando o CRC calculado pelo receptor não bate com o FCS recebido?',
        alternativas: [
          'O quadro é corrigido automaticamente',
          'O quadro é considerado corrompido e descartado',
          'O quadro é reencaminhado para outro dispositivo',
          'Nada acontece, o quadro é aceito normalmente',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, a Camada de Enlace corrige erros automaticamente?',
        alternativas: [
          'Sim, sempre corrige e reenvia o quadro sozinha',
          'Não — ela detecta e descarta; a retransmissão cabe a camadas superiores',
          'Sim, mas apenas em redes sem fio',
          'Não, ela ignora completamente qualquer erro',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que o bit de paridade simples pode falhar?',
        alternativas: [
          'Porque não existe hardware capaz de calculá-lo',
          'Porque quando dois bits são corrompidos ao mesmo tempo, o erro pode passar despercebido',
          'Porque ele só funciona em fibra óptica',
          'Porque ele exige um endereço IP válido',
        ],
        correta: 1,
      ),
    ],
  ),

  '2_4': const FaseContent(
    titulo: 'Labirinto MAC',
    conteudo:
        'Todo dispositivo com interface de rede possui um endereço MAC (Media Access Control): um identificador de 48 bits, geralmente escrito em hexadecimal (ex.: AC:DE:48:00:11:22). Diferente do IP, o MAC é (em teoria) fixo e gravado de fábrica na placa de rede, funcionando como uma "identidade física" do dispositivo dentro da rede local.\n\n'
        'O endereço MAC se divide em duas metades: os primeiros 24 bits formam o OUI (Organizationally Unique Identifier), que identifica o fabricante da interface de rede; os últimos 24 bits são definidos pelo fabricante para tornar cada interface única. Endereços MAC podem ser unicast (um-para-um), multicast (um grupo) e broadcast (FF:FF:FF:FF:FF:FF, endereçado a todos).\n\n'
        'Como a Camada de Rede trabalha com endereços IP e a Camada de Enlace trabalha com MAC, é preciso o protocolo ARP (Address Resolution Protocol). Quando um dispositivo sabe o IP de destino mas não sabe o MAC correspondente, ele envia uma requisição ARP em broadcast perguntando "quem tem esse IP?"; o dono do IP responde com seu endereço MAC, e essa associação fica guardada no cache ARP.',
    perguntas: [
      Pergunta(
        enunciado: 'Quantos bits tem um endereço MAC, segundo o texto?',
        alternativas: ['24 bits', '32 bits', '48 bits', '64 bits'],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'O que representam os primeiros 24 bits de um endereço MAC (o OUI)?',
        alternativas: [
          'O endereço IP do dispositivo',
          'O fabricante da interface de rede',
          'A porta do switch usada',
          'O protocolo de transporte utilizado',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que é um endereço MAC do tipo broadcast, segundo o texto?',
        alternativas: [
          'Um endereço que identifica apenas uma interface',
          'FF:FF:FF:FF:FF:FF, endereçado a todos os dispositivos da rede local',
          'Um endereço reservado exclusivamente para roteadores',
          'Um endereço usado apenas em fibra óptica',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a função do protocolo ARP, conforme descrito no texto?',
        alternativas: [
          'Traduzir nomes de domínio em endereços IP',
          'Descobrir o endereço MAC correspondente a um endereço IP conhecido, dentro da mesma rede local',
          'Criptografar quadros da Camada de Enlace',
          'Detectar erros de CRC nos quadros',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Onde fica guardada temporariamente a associação entre IP e MAC aprendida via ARP?',
        alternativas: ['No cabeçalho do pacote IP', 'No cache ARP', 'No FCS do quadro', 'Na tabela de rotas do roteador'],
        correta: 1,
      ),
    ],
  ),

  '2_5': const FaseContent(
    titulo: 'A Colisão',
    conteudo:
        'Quando vários dispositivos compartilham o mesmo meio físico, surge um problema: e se dois dispositivos transmitirem ao mesmo tempo? Os sinais se sobrepõem e viram ruído — uma colisão.\n\n'
        'Redes Ethernet clássicas resolviam isso com CSMA/CD (Carrier Sense Multiple Access with Collision Detection): antes de transmitir, o dispositivo "escuta" o meio; se estiver livre, transmite; se detectar uma colisão durante a transmissão, para imediatamente, envia um jam signal e espera um tempo aleatório (backoff) antes de tentar novamente.\n\n'
        'Já em redes sem fio, o Wi-Fi usa CSMA/CA (Collision Avoidance): em vez de detectar a colisão depois que ela ocorre, o protocolo tenta evitá-la antes, usando confirmações explícitas e tempos de espera aleatórios antes de cada transmissão.\n\n'
        'Esses conceitos se conectam a: domínio de colisão (conjunto de dispositivos que podem colidir entre si) e o modo half-duplex (transmite OU recebe por vez, sujeito a colisão) versus full-duplex (transmite E recebe simultaneamente, sem colisão possível).',
    perguntas: [
      Pergunta(
        enunciado: 'O que caracteriza uma colisão, segundo o texto?',
        alternativas: [
          'Dois dispositivos transmitindo ao mesmo tempo, fazendo os sinais se sobreporem e virarem ruído',
          'Um erro detectado pelo CRC',
          'A perda de sincronização na codificação Manchester',
          'A falha de um endereço ARP',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que o dispositivo faz ao detectar uma colisão usando CSMA/CD?',
        alternativas: [
          'Ignora e continua transmitindo normalmente',
          'Para imediatamente, envia um jam signal e espera um tempo aleatório (backoff) antes de tentar novamente',
          'Desliga a interface de rede permanentemente',
          'Envia o quadro por um caminho alternativo automaticamente',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que o Wi-Fi usa CSMA/CA em vez de CSMA/CD?',
        alternativas: [
          'Porque detectar colisões diretamente é praticamente impossível em redes sem fio',
          'Porque o Wi-Fi não sofre com colisões',
          'Porque o CSMA/CD é mais rápido para redes sem fio',
          'Porque o CSMA/CA não usa tempos de espera',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que é um domínio de colisão, segundo o texto?',
        alternativas: [
          'O conjunto de endereços MAC de um switch',
          'O conjunto de dispositivos que podem colidir entre si',
          'A quantidade de portas de um roteador',
          'O tempo de vida de um pacote IP',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual a diferença entre half-duplex e full-duplex, conforme o texto?',
        alternativas: [
          'Half-duplex transmite e recebe ao mesmo tempo; full-duplex só transmite',
          'Half-duplex transmite OU recebe por vez, sujeito a colisão; full-duplex transmite E recebe simultaneamente, sem colisão',
          'Ambos são idênticos em desempenho',
          'Full-duplex só existe em redes sem fio',
        ],
        correta: 1,
      ),
    ],
  ),

  // =====================================================================
  // MUNDO 3 — CAMADA DE REDE
  // =====================================================================

  '3_1': const FaseContent(
    titulo: 'A Cidade dos Pacotes',
    conteudo:
        'Enquanto a Camada de Enlace só entende sua rede local, a Camada de Rede pensa em escala de cidade inteira: várias redes locais interligadas. Para isso, ela usa o pacote e o endereço IP.\n\n'
        'Diferente do endereço MAC (fixo, gravado na placa de rede), o endereço IP é lógico e hierárquico: ele carrega informação sobre em qual rede o dispositivo está, de forma parecida com um endereço postal. Essa hierarquia permite que um pacote seja encaminhado de rede em rede até chegar ao destino final.\n\n'
        'O processo de encapsulamento continua: a Camada de Transporte entrega um segmento à Camada de Rede, que adiciona um cabeçalho IP formando um pacote; esse pacote é entregue à Camada de Enlace, que o encapsula dentro de um quadro. Um mesmo pacote pode "trocar de quadro" várias vezes ao longo do caminho — cada rede local atravessada usa seu próprio endereçamento MAC — mas o endereço IP de origem e destino permanece o mesmo do início ao fim da viagem.',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a unidade de dados característica da Camada de Rede?',
        alternativas: ['Quadro', 'Pacote', 'Segmento', 'Bit'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a principal diferença entre endereço IP e endereço MAC, segundo o texto?',
        alternativas: [
          'O IP é lógico e hierárquico; o MAC é fixo e sem relação com localização',
          'Ambos são idênticos e intercambiáveis',
          'O MAC é usado apenas na internet; o IP apenas em redes locais',
          'O IP é definido de fábrica na placa de rede',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que permite que um pacote seja encaminhado de rede em rede até o destino final?',
        alternativas: ['A hierarquia do endereço IP', 'O bit de paridade', 'A codificação Manchester', 'O domínio de colisão'],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que acontece com o endereço MAC ao longo do trajeto de um pacote por várias redes locais?',
        alternativas: [
          'Ele permanece o mesmo do início ao fim',
          'Ele pode mudar a cada rede local atravessada, enquanto o IP permanece o mesmo',
          'Ele é removido completamente do pacote',
          'Ele se transforma em endereço IP',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Como o texto descreve o processo de formação de um pacote?',
        alternativas: [
          'A Camada de Rede recebe um segmento da Camada de Transporte e adiciona um cabeçalho IP',
          'A Camada Física adiciona o endereço IP diretamente aos bits',
          'O pacote é formado apenas pela Camada de Aplicação',
          'O pacote nunca contém endereço de origem',
        ],
        correta: 0,
      ),
    ],
  ),

  '3_2': const FaseContent(
    titulo: 'Os Roteadores da Cidade',
    conteudo:
        'Se o switch é o "guarda de trânsito" dentro de um bairro (rede local), o roteador é quem conecta bairros diferentes (redes diferentes) entre si — e é o principal dispositivo da Camada de Rede. Um roteador possui múltiplas interfaces, cada uma conectada a uma rede diferente, e sua tarefa central é decidir, para cada pacote, por qual interface ele deve seguir.\n\n'
        'Essa decisão é tomada consultando a tabela de roteamento: uma lista que relaciona redes de destino, a interface (ou "próximo salto"/next hop) por onde alcançá-las, e uma métrica de custo. Ao receber um pacote, o roteador examina o endereço IP de destino e escolhe a rota mais específica e de menor custo; se não encontrar correspondência, usa uma rota padrão (default route).\n\n'
        'O switch opera dentro de uma rede local, usando endereços MAC; o roteador opera entre redes diferentes, usando endereços IP. Cada vez que um pacote passa por um roteador, dizemos que ele deu um salto (hop).',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a tarefa central de um roteador, segundo o texto?',
        alternativas: [
          'Regenerar sinais elétricos',
          'Decidir por qual interface um pacote deve seguir para se aproximar do destino',
          'Atribuir endereços MAC às interfaces',
          'Detectar colisões em um meio compartilhado',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que contém uma tabela de roteamento, conforme descrito no texto?',
        alternativas: [
          'Redes de destino, interface/próximo salto e uma métrica de custo',
          'Apenas endereços MAC de dispositivos locais',
          'Apenas os nomes de domínio conhecidos',
          'O histórico de colisões da rede',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que é uma "rota padrão (default route)", segundo o texto?',
        alternativas: [
          'A única rota permitida em qualquer rede',
          'A rota usada quando nenhuma correspondência é encontrada na tabela de roteamento',
          'Uma rota exclusiva para tráfego de broadcast',
          'Um tipo de endereço MAC',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a diferença de escopo entre switch e roteador, segundo o texto?',
        alternativas: [
          'O switch opera dentro de uma rede local (MAC); o roteador opera entre redes diferentes (IP)',
          'Ambos operam exatamente da mesma forma',
          'O roteador usa apenas endereços MAC',
          'O switch conecta redes diferentes; o roteador conecta dispositivos na mesma rede',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que o texto chama de "salto (hop)"?',
        alternativas: [
          'Uma colisão detectada pelo CSMA/CD',
          'Cada vez que um pacote passa por um roteador',
          'A troca de endereço IP de um dispositivo',
          'Um erro de CRC corrigido automaticamente',
        ],
        correta: 1,
      ),
    ],
  ),

  '3_3': const FaseContent(
    titulo: 'Roteamento Perdido',
    conteudo:
        'Como um roteador sabe quais rotas colocar em sua tabela? Existem duas abordagens. No roteamento estático, um administrador configura manualmente cada rota — simples e previsível, mas não se adapta sozinho a mudanças. No roteamento dinâmico, os roteadores trocam informações entre si automaticamente, usando protocolos de roteamento.\n\n'
        'Dentro do roteamento dinâmico, duas famílias se destacam. Os protocolos de vetor de distância (como o RIP) funcionam por "boato": cada roteador informa aos vizinhos quais redes conhece e a que distância — simples, mas lento para se adaptar. Já os protocolos de estado de enlace (como o OSPF) fazem cada roteador anunciar o estado de suas conexões diretas, permitindo que cada um construa um mapa completo da topologia — mais complexo, porém mais rápido na convergência.\n\n'
        'Um problema comum é o loop de roteamento: um pacote fica sendo redirecionado em círculos entre roteadores. Para evitar isso, todo pacote IP carrega um campo TTL (Time To Live): um contador que diminui a cada salto; quando chega a zero, o pacote é descartado.',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a diferença entre roteamento estático e dinâmico, segundo o texto?',
        alternativas: [
          'No estático, rotas são configuradas manualmente; no dinâmico, roteadores trocam informações automaticamente',
          'O estático sempre se adapta sozinho a falhas',
          'O dinâmico exige configuração manual constante',
          'Não há diferença prática entre os dois',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Como funcionam os protocolos de vetor de distância, segundo o texto?',
        alternativas: [
          'Cada roteador constrói um mapa completo da topologia sozinho',
          'Cada roteador informa aos vizinhos quais redes conhece e a que distância, funcionando por "boato"',
          'Cada roteador ignora completamente os vizinhos',
          'Cada roteador usa apenas endereços MAC para decidir rotas',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que diferencia os protocolos de estado de enlace (como o OSPF)?',
        alternativas: [
          'Cada roteador anuncia o estado de suas conexões diretas, permitindo montar um mapa completo da topologia',
          'Eles não trocam nenhuma informação entre roteadores',
          'Eles dependem exclusivamente de configuração manual',
          'Eles usam apenas o endereço MAC de destino',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que é um "loop de roteamento", segundo o texto?',
        alternativas: [
          'Uma rota configurada estaticamente com sucesso',
          'Um pacote sendo redirecionado em círculos entre roteadores, sem nunca chegar ao destino',
          'A troca automática de rotas dinâmicas',
          'Um erro de CRC detectado pela Camada de Enlace',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a função do campo TTL (Time To Live)?',
        alternativas: [
          'Definir a largura de banda do pacote',
          'Diminuir uma unidade a cada salto e descartar o pacote quando chegar a zero, evitando loops infinitos',
          'Criptografar o conteúdo do pacote',
          'Definir o endereço MAC de destino',
        ],
        correta: 1,
      ),
    ],
  ),

  '3_4': const FaseContent(
    titulo: 'Sub-redes da Periferia',
    conteudo:
        'Um endereço IPv4 tem 32 bits, escrito em quatro números decimais separados por pontos (ex.: 192.168.1.10). Esse endereço se divide em duas partes: uma porção de rede e uma porção de host. A máscara de sub-rede define onde termina a parte de rede e começa a parte de host — por exemplo, a máscara 255.255.255.0 (CIDR /24) indica que os primeiros 24 bits identificam a rede.\n\n'
        'Sub-redes (subnetting) é o processo de dividir uma rede grande em redes menores, "emprestando" bits da porção de host. Três motivos: organização (separar setores), redução de domínio de broadcast (redes menores = menos tráfego broadcast) e segurança (isolar tráfego sensível).\n\n'
        'Exemplo: pegar a rede 192.168.1.0/24 (256 endereços) e dividi-la em quatro sub-redes /26 (64 endereços cada). Cada sub-rede tem seu próprio endereço de rede, faixa de hosts e endereço de broadcast.',
    perguntas: [
      Pergunta(
        enunciado: 'O que a máscara de sub-rede define, segundo o texto?',
        alternativas: [
          'O fabricante da placa de rede',
          'Onde termina a porção de rede e começa a porção de host de um endereço IP',
          'A velocidade máxima do enlace',
          'O tipo de codificação de linha usada',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que a notação CIDR /24 representa, conforme o texto?',
        alternativas: [
          '24 dispositivos conectados',
          'Os primeiros 24 bits do endereço identificam a rede',
          '24 sub-redes disponíveis',
          '24 saltos até o destino',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais são os três motivos para se fazer subnetting, segundo o texto?',
        alternativas: [
          'Organização, redução de domínio de broadcast e segurança',
          'Aumentar a atenuação, o ruído e a distorção',
          'Eliminar a necessidade de endereços MAC',
          'Aumentar o TTL dos pacotes',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'No exemplo do texto, quantos endereços possui cada sub-rede /26?',
        alternativas: ['256', '128', '64', '32'],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que cada sub-rede resultante possui?',
        alternativas: [
          'Um endereço de rede próprio, faixa de hosts utilizáveis e endereço de broadcast próprios',
          'Um endereço MAC único para toda a sub-rede',
          'Uma tabela de roteamento idêntica à rede original',
          'Nenhuma relação com o bloco IP original',
        ],
        correta: 0,
      ),
    ],
  ),

  '3_5': const FaseContent(
    titulo: 'Conflito de Identidades',
    conteudo:
        'Nem todo endereço IP é igual em propósito. Endereços públicos são únicos no mundo inteiro e roteáveis na internet; endereços privados (faixas como 10.0.0.0/8, 172.16.0.0/12 e 192.168.0.0/16) são de uso livre dentro de redes locais, mas não são roteáveis na internet pública.\n\n'
        'Para que dispositivos com IP privado acessem a internet, entra em cena o NAT (Network Address Translation): o roteador doméstico traduz o IP privado de cada dispositivo interno para o único IP público da conexão.\n\n'
        'E como cada dispositivo recebe seu IP? Via DHCP (Dynamic Host Configuration Protocol): quando um dispositivo entra na rede, ele solicita um endereço, e um servidor DHCP lhe empresta um IP livre por um tempo limitado (o "lease"). Isso evita conflito de IP (quando dois dispositivos usam o mesmo endereço, causando falhas intermitentes). A limitação de endereços IPv4 é uma das razões que motivam a adoção do IPv6, que usa 128 bits.',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a diferença entre IP público e IP privado, segundo o texto?',
        alternativas: [
          'IP público é único no mundo e roteável na internet; IP privado é de uso livre em redes locais e não roteável na internet',
          'Ambos são idênticos em função',
          'IP privado é sempre mais rápido que o público',
          'IP público só existe em redes sem fio',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Qual é a função do NAT, conforme descrito no texto?',
        alternativas: [
          'Atribuir endereços MAC às interfaces',
          'Traduzir o IP privado de cada dispositivo interno para o único IP público da conexão',
          'Detectar colisões em uma rede compartilhada',
          'Dividir uma rede em sub-redes menores',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que faz o DHCP, segundo o texto?',
        alternativas: [
          'Empresta automaticamente um endereço IP livre a um dispositivo que entra na rede, por tempo limitado',
          'Traduz nomes de domínio em endereços IP',
          'Detecta erros de CRC em quadros',
          'Define a rota padrão de um roteador',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que caracteriza um "conflito de IP"?',
        alternativas: [
          'Dois dispositivos usando simultaneamente o mesmo endereço, causando falhas intermitentes',
          'Um roteador com duas interfaces de rede',
          'Uma sub-rede com máscara /24',
          'Um pacote com TTL zerado',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, qual é uma das razões que motivam a adoção do IPv6?',
        alternativas: [
          'A limitação de endereços disponíveis no IPv4',
          'A necessidade de eliminar o NAT completamente',
          'A substituição obrigatória de todos os switches',
          'A eliminação do protocolo DHCP',
        ],
        correta: 0,
      ),
    ],
  ),

  '3_6': const FaseContent(
    titulo: 'O Roteador Central',
    conteudo:
        'Fechando o Mundo 3, vale revisar como diagnosticamos o caminho de um pacote. O protocolo ICMP (Internet Control Message Protocol) é usado para trocar mensagens de controle e diagnóstico — não transporta dados de aplicação, mas informações sobre a própria rede.\n\n'
        'Duas ferramentas populares usam ICMP: o ping, que envia um "echo request" e mede quanto tempo leva para receber o "echo reply", testando se um host está acessível e qual a latência; e o traceroute, que revela cada roteador (salto) atravessado até o destino, enviando pacotes com TTL crescente (1, 2, 3...) — a cada vez que o TTL chega a zero, o roteador intermediário responde com uma mensagem ICMP de "tempo excedido", revelando sua identidade.\n\n'
        'Resumo do Mundo 3: pacotes carregam endereços IP hierárquicos; roteadores decidem o caminho; máscaras de sub-rede organizam redes; NAT e DHCP resolvem a escassez e distribuição de endereços; e TTL + ICMP garantem robustez e diagnóstico.',
    perguntas: [
      Pergunta(
        enunciado: 'Para que serve o protocolo ICMP, segundo o texto?',
        alternativas: [
          'Transportar dados de aplicação entre servidores web',
          'Trocar mensagens de controle e diagnóstico sobre a própria rede',
          'Atribuir endereços IP dinamicamente',
          'Criptografar pacotes sensíveis',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que o comando ping mede, de acordo com o texto?',
        alternativas: [
          'O número de sub-redes de uma rede',
          'Se um host está acessível e a latência até ele, via echo request/echo reply',
          'A largura de banda máxima de um cabo',
          'O endereço MAC de um dispositivo remoto',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Como o traceroute descobre cada roteador no caminho até o destino?',
        alternativas: [
          'Perguntando diretamente ao servidor DNS',
          'Enviando pacotes com TTL crescente e capturando as respostas ICMP de "tempo excedido"',
          'Lendo a tabela de roteamento do destino final',
          'Usando exclusivamente o protocolo ARP',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, o que garante que a rede seja "robusta contra loops"?',
        alternativas: ['O DHCP', 'O TTL, combinado com ICMP', 'O NAT', 'A máscara de sub-rede'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a visão geral do Mundo 3 resumida no texto?',
        alternativas: [
          'Pacotes com IP hierárquico, roteadores com tabelas, sub-redes, NAT/DHCP e TTL/ICMP formam o núcleo lógico da rede',
          'Apenas os endereços MAC importam para a comunicação entre redes',
          'A Camada de Rede não depende de endereçamento algum',
          'Roteadores nunca usam tabelas para decidir caminhos',
        ],
        correta: 0,
      ),
    ],
  ),

  // =====================================================================
  // MUNDO 4 — CAMADA DE TRANSPORTE
  // =====================================================================

  '4_1': const FaseContent(
    titulo: 'Os Portões dos Protocolos',
    conteudo:
        'Um computador pode rodar dezenas de aplicações usando a rede ao mesmo tempo. Todas compartilham o mesmo endereço IP — então como a rede sabe entregar cada dado à aplicação certa? A resposta é a porta: um número de 16 bits (de 0 a 65535) que identifica um processo específico. A combinação de endereço IP + porta forma um socket.\n\n'
        'Esse mecanismo é chamado de multiplexação/demultiplexação: na origem, a Camada de Transporte junta dados de várias aplicações (multiplexação); no destino, distribui os dados recebidos para a aplicação correta com base na porta (demultiplexação).\n\n'
        'Muitas portas são padronizadas — as portas conhecidas (well-known ports), como 80 (HTTP), 443 (HTTPS), 53 (DNS) e 25 (SMTP). É nessa camada que vivem o TCP (orientado a conexão e confiável) e o UDP (sem conexão e mais rápido).',
    perguntas: [
      Pergunta(
        enunciado: 'O que identifica um processo específico rodando em uma máquina, segundo o texto?',
        alternativas: ['O endereço MAC', 'A porta (número de 16 bits)', 'O TTL do pacote', 'A máscara de sub-rede'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que forma um socket, de acordo com o texto?',
        alternativas: [
          'Apenas o endereço IP',
          'A combinação de endereço IP + porta',
          'Apenas o endereço MAC',
          'A combinação de porta + TTL',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que é demultiplexação, segundo o texto?',
        alternativas: [
          'Juntar dados de várias aplicações para enviar pela mesma interface',
          'Distribuir os dados recebidos para a aplicação correta com base na porta de destino',
          'Dividir uma rede em sub-redes',
          'Traduzir um IP privado em um IP público',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais exemplos de "portas conhecidas" o texto cita?',
        alternativas: [
          '80 (HTTP), 443 (HTTPS), 53 (DNS) e 25 (SMTP)',
          '10, 20, 30 e 40',
          'Apenas a porta 8080',
          '24, 48 e 64',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Quais são os dois protocolos principais da Camada de Transporte citados no texto?',
        alternativas: ['ARP e ICMP', 'TCP e UDP', 'DNS e HTTP', 'DHCP e NAT'],
        correta: 1,
      ),
    ],
  ),

  '4_2': const FaseContent(
    titulo: 'O Aperto de Mãos',
    conteudo:
        'O TCP é chamado de protocolo orientado a conexão porque, antes de qualquer dado ser trocado, os dois lados precisam concordar em iniciar uma "conversa" formal. Esse processo é o three-way handshake: primeiro, o cliente envia SYN ("quero sincronizar"); o servidor responde com SYN-ACK ("aceito"); e o cliente finaliza com ACK ("confirmado"). Só depois a conexão é estabelecida.\n\n'
        'Esse handshake confirma que ambos os lados estão ativos e sincroniza os números de sequência iniciais.\n\n'
        'Encerrar uma conexão TCP também segue um processo formal, com trocas de segmentos FIN confirmadas por ACKs — um "encerramento educado" da conversa. Esse cuidado no início e no fim da conexão é uma das razões pelas quais o TCP é considerado confiável: nenhum dos lados começa ou termina de trocar dados sem confirmação explícita do outro.',
    perguntas: [
      Pergunta(
        enunciado: 'Por que o TCP é chamado de "orientado a conexão", segundo o texto?',
        alternativas: [
          'Porque os dois lados precisam concordar em iniciar uma conexão formal antes de trocar dados',
          'Porque ele não usa portas',
          'Porque ele não precisa de endereço IP',
          'Porque ele sempre usa a porta 53',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Quais são os três passos do three-way handshake, conforme o texto?',
        alternativas: ['SYN, SYN-ACK, ACK', 'FIN, ACK, SYN', 'ACK, SYN, FIN', 'SYN, FIN, SYN-ACK'],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Quais são os dois propósitos práticos do handshake, segundo o texto?',
        alternativas: [
          'Confirmar que ambos os lados estão ativos e sincronizar os números de sequência iniciais',
          'Definir o endereço MAC de cada lado e calcular o CRC',
          'Escolher a rota mais curta entre roteadores',
          'Traduzir o IP privado em IP público',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Como o texto descreve o encerramento de uma conexão TCP?',
        alternativas: [
          'Os dados simplesmente param de ser enviados sem aviso',
          'Um processo formal, com trocas de segmentos FIN confirmadas por ACKs',
          'Ocorre automaticamente após 24 horas',
          'Não existe processo de encerramento no TCP',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Segundo o texto, por que o cuidado no início e fim da conexão torna o TCP confiável?',
        alternativas: [
          'Porque nenhum dos lados começa ou termina de trocar dados sem confirmação explícita do outro',
          'Porque o TCP nunca usa números de sequência',
          'Porque o TCP não depende de portas',
          'Porque o TCP usa apenas UDP internamente',
        ],
        correta: 0,
      ),
    ],
  ),

  '4_3': const FaseContent(
    titulo: 'Controle de Fluxo',
    conteudo:
        'Estabelecida a conexão, o TCP precisa garantir que os dados cheguem completos e na ordem certa. Para isso, usa três mecanismos.\n\n'
        'O controle de fluxo evita que o emissor sobrecarregue o receptor: o receptor informa o tamanho do seu buffer livre (a janela deslizante) e o emissor nunca envia mais dados do que esse espaço permite.\n\n'
        'O controle de congestionamento olha para a rede como um todo: se o TCP perceber sinais de congestionamento (perda de segmentos, atrasos crescentes), ele reduz a quantidade de dados enviada por vez e vai aumentando aos poucos.\n\n'
        'A confirmação (ACK) e retransmissão garantem que nada se perca: cada segmento recebido é confirmado; se o emissor não recebe a confirmação dentro de um tempo esperado (timeout), ele retransmite automaticamente. Juntos, esses três mecanismos — janela deslizante, controle de congestionamento e retransmissão — tornam o TCP confiável.',
    perguntas: [
      Pergunta(
        enunciado: 'O que é a "janela deslizante (sliding window)", segundo o texto?',
        alternativas: [
          'O tamanho do espaço de buffer livre que o receptor informa ao emissor',
          'O tempo de vida de um pacote IP',
          'A tabela de roteamento de um roteador',
          'O número de portas disponíveis em um dispositivo',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Qual a diferença entre controle de fluxo e controle de congestionamento?',
        alternativas: [
          'Controle de fluxo evita sobrecarregar o receptor; controle de congestionamento olha para a rede como um todo',
          'São exatamente o mesmo mecanismo com nomes diferentes',
          'Controle de fluxo lida com a rede; controle de congestionamento lida só com o receptor',
          'Nenhum dos dois existe no TCP',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que acontece quando o emissor não recebe a confirmação (ACK) de um segmento dentro do tempo esperado?',
        alternativas: [
          'Ele descarta a conexão permanentemente',
          'Ele assume que o segmento se perdeu e o retransmite',
          'Ele ignora e segue para o próximo segmento',
          'Ele reduz a porta de origem',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Como o controle de congestionamento reage a sinais de perda de segmentos?',
        alternativas: [
          'Aumenta drasticamente a quantidade de dados enviada',
          'Reduz a quantidade de dados enviada por vez e vai aumentando aos poucos',
          'Encerra a conexão imediatamente',
          'Troca o protocolo para UDP automaticamente',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais três mecanismos tornam o TCP confiável, segundo o texto?',
        alternativas: [
          'Janela deslizante, controle de congestionamento e retransmissão por timeout',
          'SYN, SYN-ACK e ACK apenas',
          'NAT, DHCP e ARP',
          'CRC, paridade e checksum',
        ],
        correta: 0,
      ),
    ],
  ),

  '4_4': const FaseContent(
    titulo: 'TCP ou UDP?',
    conteudo:
        'Nem toda aplicação precisa da confiabilidade do TCP. O UDP (User Datagram Protocol) é sem conexão (não há handshake), não garante entrega, não garante ordem e não faz controle de fluxo ou congestionamento. Em troca, oferece menos overhead e menor latência.\n\n'
        'A escolha depende do que a aplicação valoriza: confiabilidade ou velocidade/baixa latência. Navegação web, transferência de arquivos e e-mail usam TCP — perder um pedaço seria inaceitável. Streaming de vídeo ao vivo, VoIP, jogos online e consultas DNS usam UDP — um pequeno defeito momentâneo é preferível a um atraso perceptível.\n\n'
        'Em resumo: TCP é como enviar uma carta registrada, com confirmação de entrega; UDP é como gritar uma mensagem para o outro lado da rua — mais rápido, mas sem garantia.',
    perguntas: [
      Pergunta(
        enunciado: 'Quais características do UDP são citadas no texto?',
        alternativas: [
          'Sem conexão, sem garantia de entrega ou ordem, sem controle de fluxo/congestionamento',
          'Orientado a conexão, com handshake obrigatório',
          'Garante 100% de entrega ordenada',
          'Usa números de sequência para reordenar dados',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Qual é a principal vantagem do UDP sobre o TCP, segundo o texto?',
        alternativas: [
          'Menos overhead e menor latência',
          'Maior confiabilidade',
          'Handshake mais robusto',
          'Controle de congestionamento mais eficiente',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Quais aplicações o texto cita como usuárias típicas de TCP?',
        alternativas: [
          'Streaming de vídeo ao vivo e jogos online',
          'Navegação web, transferência de arquivos e e-mail',
          'Chamadas de voz em tempo real',
          'Consultas DNS',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais aplicações o texto cita como usuárias típicas de UDP?',
        alternativas: [
          'Transferência de arquivos e e-mail',
          'Streaming de vídeo ao vivo, VoIP, jogos online e consultas DNS',
          'Apenas navegação web',
          'Apenas backups de longo prazo',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual analogia o texto usa para diferenciar TCP e UDP?',
        alternativas: [
          'TCP é como uma carta registrada; UDP é como gritar uma mensagem sem garantia de ter sido ouvida',
          'TCP é como um rádio; UDP é como um telefone',
          'Ambos são como cartas registradas',
          'Ambos são como gritar uma mensagem',
        ],
        correta: 0,
      ),
    ],
  ),

  '4_5': const FaseContent(
    titulo: 'A Fábrica de Segmentos',
    conteudo:
        'Quando uma aplicação entrega um grande volume de dados, o TCP quebra o fluxo em pedaços menores chamados segmentos, cada um com seu próprio cabeçalho.\n\n'
        'O cabeçalho de um segmento TCP carrega: porta de origem e porta de destino; o número de sequência (posição do primeiro byte no fluxo total); o número de confirmação (ACK number, próximo byte esperado); e flags de controle (SYN, ACK, FIN).\n\n'
        'É o número de sequência que resolve o problema de segmentos que chegam fora de ordem (cada um pode seguir uma rota diferente). No destino, a Camada de Transporte usa os números de sequência para reordenar os segmentos antes de entregar os dados à aplicação — que nunca precisa se preocupar com a ordem real de chegada pela rede.',
    perguntas: [
      Pergunta(
        enunciado: 'O que é um segmento, segundo o texto?',
        alternativas: [
          'A menor unidade de informação (0 ou 1)',
          'Um pedaço menor em que o TCP divide o fluxo de dados, com seu próprio cabeçalho',
          'O endereço MAC de um dispositivo',
          'Um tipo de meio de transmissão',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Para que serve o número de sequência em um segmento TCP?',
        alternativas: [
          'Identificar a posição do primeiro byte daquele segmento dentro do fluxo total de dados',
          'Definir a porta de destino da aplicação',
          'Indicar o fabricante da interface de rede',
          'Definir a máscara de sub-rede',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Por que segmentos podem chegar fora de ordem no destino?',
        alternativas: [
          'Porque cada um pode seguir uma rota diferente entre origem e destino',
          'Porque o TCP embaralha os segmentos de propósito',
          'Porque o UDP é usado internamente pelo TCP',
          'Porque o endereço IP muda a cada segmento',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que a Camada de Transporte faz com os segmentos ao chegarem no destino?',
        alternativas: [
          'Descarta os que chegam fora de ordem',
          'Usa os números de sequência para reordená-los antes de entregar os dados à aplicação',
          'Entrega os dados à aplicação na ordem de chegada pela rede',
          'Converte os segmentos de volta em bits crus',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais informações o cabeçalho de um segmento TCP carrega?',
        alternativas: [
          'Porta de origem/destino, número de sequência, número de confirmação e flags de controle',
          'Apenas o endereço IP de origem',
          'Apenas o endereço MAC de destino',
          'Apenas a máscara de sub-rede',
        ],
        correta: 0,
      ),
    ],
  ),

  // =====================================================================
  // MUNDO 5 — CAMADA DE APLICAÇÃO
  // =====================================================================

  '5_1': const FaseContent(
    titulo: 'A Metrópole Digital',
    conteudo:
        'Chegamos à camada que o usuário final realmente "vê". A Camada de Aplicação define os protocolos que as próprias aplicações usam para se comunicar: como um navegador pede uma página (HTTP), como um e-mail é enviado (SMTP) ou como um nome de site vira um endereço IP (DNS).\n\n'
        'A maioria das aplicações segue o modelo cliente-servidor: o cliente inicia a comunicação solicitando algo; o servidor responde. Um mesmo servidor pode atender milhares de clientes, cada conexão distinguida por seu socket (IP + porta).\n\n'
        'A jornada completa de um dado: a aplicação gera a informação; a Camada de Transporte a divide em segmentos com portas; a Camada de Rede envolve cada segmento em um pacote com endereços IP; a Camada de Enlace envolve o pacote em um quadro com endereços MAC; e a Camada Física transforma tudo em sinais. Esse processo chama-se encapsulamento, e o inverso, decapsulamento.',
    perguntas: [
      Pergunta(
        enunciado: 'O que a Camada de Aplicação define, segundo o texto?',
        alternativas: [
          'Os protocolos que as próprias aplicações usam para se comunicar',
          'Apenas os endereços MAC dos dispositivos',
          'Apenas as tabelas de roteamento',
          'Apenas os níveis de voltagem do sinal',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Como o texto descreve o modelo cliente-servidor?',
        alternativas: [
          'O cliente inicia a comunicação solicitando algo; o servidor responde',
          'O servidor sempre inicia a comunicação',
          'Cliente e servidor são sempre a mesma máquina',
          'Não existe distinção entre cliente e servidor',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que distingue cada conexão simultânea que um servidor atende?',
        alternativas: [
          'O endereço MAC do servidor',
          'O socket (IP + porta) de cada conexão',
          'O TTL do pacote',
          'O tipo de meio de transmissão usado',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Como o texto chama o processo de "envolver cada camada com sua própria informação"?',
        alternativas: ['Decapsulamento', 'Encapsulamento', 'Multiplexação', 'Subnetting'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a ordem de "envolvimento" de um dado ao descer pelas camadas?',
        alternativas: [
          'Aplicação gera; Transporte adiciona portas; Rede adiciona IP; Enlace adiciona MAC; Física transforma em sinal',
          'Física gera o dado; Aplicação transforma em sinal',
          'Rede gera o dado antes da aplicação',
          'Enlace é a primeira camada a processar o dado',
        ],
        correta: 0,
      ),
    ],
  ),

  '5_2': const FaseContent(
    titulo: 'O Oráculo DNS',
    conteudo:
        'Ninguém decora endereços IP — decoramos nomes, como google.com. É função do DNS (Domain Name System) traduzir nomes de domínio em endereços IP, funcionando como uma "agenda telefônica" distribuída da internet.\n\n'
        'O DNS é hierárquico: no topo estão os servidores raiz; abaixo, os servidores de TLD (como .com, .org, .br); e por fim os servidores autoritativos, que guardam a resposta definitiva sobre um domínio específico.\n\n'
        'Uma consulta DNS típica é recursiva: o dispositivo pergunta a um servidor "resolvedor", que consulta, em cascata, servidores raiz, TLD e autoritativo até obter a resposta. Respostas são guardadas em cache para acelerar consultas futuras.\n\n'
        'Tipos de registros DNS: A (nome → IPv4), AAAA (nome → IPv6), CNAME (nome → outro nome, um "apelido") e MX (servidor de e-mails do domínio).',
    perguntas: [
      Pergunta(
        enunciado: 'Qual é a função do DNS, segundo o texto?',
        alternativas: [
          'Traduzir nomes de domínio em endereços IP',
          'Detectar erros de CRC em quadros',
          'Estabelecer conexões TCP via handshake',
          'Atribuir endereços MAC às interfaces',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Quem guarda a resposta final e definitiva sobre um domínio específico?',
        alternativas: [
          'Os servidores raiz',
          'Os servidores autoritativos',
          'Os servidores de TLD',
          'O cache do navegador apenas',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que respostas DNS são guardadas em cache?',
        alternativas: [
          'Para evitar repetir todo o processo de consulta, acelerando consultas futuras',
          'Porque é obrigatório por lei',
          'Para aumentar o TTL dos pacotes IP',
          'Para substituir o servidor autoritativo',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que o registro DNS do tipo A representa?',
        alternativas: [
          'Um "apelido" para outro nome de domínio',
          'O endereço IPv4 associado a um nome de domínio',
          'O servidor responsável por receber e-mails',
          'O endereço IPv6 associado a um nome de domínio',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual registro DNS indica o servidor responsável por receber e-mails de um domínio?',
        alternativas: ['CNAME', 'AAAA', 'MX', 'A'],
        correta: 2,
      ),
    ],
  ),

  '5_3': const FaseContent(
    titulo: 'A Autoestrada HTTP',
    conteudo:
        'O HTTP (HyperText Transfer Protocol) é o protocolo que move praticamente toda a web. Funciona no modelo requisição-resposta: o cliente envia uma requisição com um método — GET (buscar), POST (enviar dados), PUT (atualizar) e DELETE (remover) — e o servidor devolve uma resposta com um código de status: 2xx = sucesso (200 = OK); 3xx = redirecionamento (301 = movido); 4xx = erro do cliente (404 = não encontrado); 5xx = erro do servidor (500 = erro interno).\n\n'
        'O HTTP é stateless (sem estado): cada requisição é independente. Para manter sessões (como um login), usam-se cookies — pequenos dados que o navegador guarda e reenvia a cada requisição.\n\n'
        'O HTTPS é o HTTP sobre TLS/SSL: antes da requisição, cliente e servidor negociam chaves criptográficas, garantindo que o conteúdo trocado não possa ser lido ou alterado por terceiros.',
    perguntas: [
      Pergunta(
        enunciado: 'Quais métodos HTTP são citados no texto?',
        alternativas: ['GET, POST, PUT e DELETE', 'SYN, ACK e FIN', 'A, AAAA e MX', 'OPEN, CLOSE e READ'],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que o código de status HTTP 404 indica, segundo o texto?',
        alternativas: [
          'Sucesso na requisição',
          'Erro do cliente (recurso não encontrado)',
          'Erro interno do servidor',
          'Redirecionamento permanente',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que significa o HTTP ser "stateless (sem estado)"?',
        alternativas: [
          'Cada requisição é tratada de forma independente, sem memória de requisições anteriores',
          'O servidor lembra permanentemente de cada cliente sem precisar de cookies',
          'O protocolo não pode ser usado por navegadores',
          'Não existem códigos de status no HTTP',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Qual é a função dos cookies, segundo o texto?',
        alternativas: [
          'Criptografar o tráfego HTTP',
          'Simular uma "sessão contínua", guardando e reenviando dados a cada requisição futura',
          'Traduzir nomes de domínio em IP',
          'Definir o método HTTP usado',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que o HTTPS adiciona ao HTTP?',
        alternativas: [
          'Uma camada de segurança (TLS/SSL) que criptografa o conteúdo trocado',
          'Um novo método de requisição chamado SECURE',
          'A eliminação completa dos códigos de status',
          'A obrigatoriedade do método POST',
        ],
        correta: 0,
      ),
    ],
  ),

  '5_4': const FaseContent(
    titulo: 'O Servidor de E-mails',
    conteudo:
        'Enviar e ler e-mails envolve três protocolos diferentes. O SMTP (Simple Mail Transfer Protocol) é usado para enviar e-mails: do cliente ao servidor do remetente, e deste ao servidor do destinatário (usando o registro MX do DNS).\n\n'
        'Para ler e-mails, existem duas abordagens. O POP3 (Post Office Protocol v3) baixa as mensagens do servidor para o dispositivo local e, tradicionalmente, as remove do servidor — funciona bem com um único dispositivo. Já o IMAP (Internet Message Access Protocol) mantém as mensagens no servidor e sincroniza a exibição entre vários dispositivos.\n\n'
        'O caminho completo: o remetente escreve a mensagem → envia via SMTP ao servidor do remetente → esse servidor localiza (via DNS/MX) o servidor do destinatário e entrega via SMTP → o destinatário acessa usando POP3 ou IMAP.',
    perguntas: [
      Pergunta(
        enunciado: 'Qual protocolo é usado para enviar e-mails, segundo o texto?',
        alternativas: ['POP3', 'IMAP', 'SMTP', 'DNS'],
        correta: 2,
      ),
      Pergunta(
        enunciado: 'Como o POP3 trata as mensagens em relação ao servidor?',
        alternativas: [
          'Mantém as mensagens no servidor indefinidamente',
          'Baixa as mensagens para o dispositivo local e, tradicionalmente, as remove do servidor',
          'Nunca baixa mensagens, apenas visualiza online',
          'Sincroniza automaticamente entre todos os dispositivos',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é a vantagem do IMAP sobre o POP3, segundo o texto?',
        alternativas: [
          'O IMAP mantém as mensagens no servidor e sincroniza entre vários dispositivos',
          'O IMAP é mais rápido para enviar e-mails',
          'O IMAP não depende de servidores',
          'O IMAP substitui completamente o SMTP',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'Como o SMTP usa o registro MX, conforme descrito no texto?',
        alternativas: [
          'Para criptografar a mensagem de e-mail',
          'Para descobrir qual servidor deve receber a mensagem do domínio de destino',
          'Para armazenar a mensagem permanentemente',
          'Para converter o e-mail em um pacote IP',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Qual é o caminho completo de um e-mail descrito no texto?',
        alternativas: [
          'Cliente envia via SMTP ao servidor do remetente, que entrega via SMTP ao servidor do destinatário; o destinatário acessa via POP3 ou IMAP',
          'O e-mail vai direto do cliente do remetente ao cliente do destinatário',
          'O e-mail é sempre lido via HTTP',
          'O SMTP é usado tanto para enviar quanto para ler e-mails',
        ],
        correta: 0,
      ),
    ],
  ),

  '5_5': const FaseContent(
    titulo: 'A Invasão Malware',
    conteudo:
        'Toda a infraestrutura estudada até aqui também é alvo de ataques. Malware é o termo genérico para software malicioso: vírus (se anexa a um programa legítimo), worm (se espalha sozinho pela rede), trojan (se disfarça de programa legítimo) e ransomware (criptografa os arquivos da vítima e exige pagamento). Phishing é uma técnica de engenharia social usando mensagens falsas para roubar dados.\n\n'
        'Na defesa, o firewall analisa o tráfego de entrada e saída, permitindo ou bloqueando pacotes com base em regras. A criptografia protege dados em trânsito (HTTPS) e em repouso.\n\n'
        'Dois ataques importantes: o DDoS (Distributed Denial of Service) inunda um servidor com tráfego de milhares de dispositivos; e o man-in-the-middle intercepta a comunicação entre duas partes em redes não criptografadas. Boas práticas — manter sistemas atualizados, usar senhas fortes, preferir HTTPS e usar VPN em redes públicas — reduzem esses riscos.',
    perguntas: [
      Pergunta(
        enunciado: 'Qual a diferença entre vírus e worm, segundo o texto?',
        alternativas: [
          'O vírus se anexa a um programa legítimo; o worm se espalha sozinho pela rede, sem hospedeiro',
          'São exatamente a mesma coisa',
          'O worm precisa de um programa hospedeiro; o vírus não',
          'Nenhum dos dois se espalha pela rede',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'O que é ransomware, de acordo com o texto?',
        alternativas: [
          'Um filtro de tráfego de rede',
          'Malware que criptografa os arquivos da vítima e exige pagamento para devolver o acesso',
          'Uma técnica de engenharia social baseada em e-mails falsos',
          'Um protocolo de criptografia usado no HTTPS',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que faz um firewall, segundo o texto?',
        alternativas: [
          'Criptografa todos os e-mails enviados',
          'Analisa o tráfego de entrada e saída, permitindo ou bloqueando pacotes com base em regras',
          'Traduz nomes de domínio em endereços IP',
          'Substitui o antivírus completamente',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Como o texto descreve um ataque DDoS?',
        alternativas: [
          'Interceptação silenciosa de tráfego não criptografado',
          'Inundação de um servidor com tráfego vindo de milhares de dispositivos simultaneamente',
          'Um tipo de vírus que se anexa a programas legítimos',
          'Uma técnica de phishing por e-mail',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Quais boas práticas o texto recomenda para reduzir riscos de segurança?',
        alternativas: [
          'Manter sistemas atualizados, usar senhas fortes, preferir HTTPS e usar VPN em redes públicas',
          'Desativar toda criptografia para acelerar a rede',
          'Usar sempre redes Wi-Fi públicas sem VPN',
          'Evitar atualizações de sistema para não gastar dados',
        ],
        correta: 0,
      ),
    ],
  ),

  '5_6': const FaseContent(
    titulo: 'O Core da Rede',
    conteudo:
        'Cenário final — a jornada completa de um dado através de toda a pilha TCP/IP.\n\n'
        'Na Camada de Aplicação, a mensagem é criada. Desce para a Camada de Transporte, que a divide em segmentos, adicionando portas e números de sequência (TCP ou UDP). Cada segmento desce para a Camada de Rede, que o envolve em um pacote com endereços IP e decide a rota. O pacote desce para a Camada de Enlace, que o envolve em um quadro com endereços MAC e CRC. Por fim, a Camada Física transforma o quadro em sinais.\n\n'
        'No destino, o processo se inverte: a Física reconverte sinais em bits; a Enlace verifica o CRC e extrai o pacote; a Rede lê o IP e extrai o segmento; a Transporte reordena os segmentos; e a Aplicação apresenta a mensagem. Cada camada resolve um problema específico — e é essa divisão de responsabilidades que permite que a internet funcione de forma confiável e escalável.',
    perguntas: [
      Pergunta(
        enunciado: 'Como o texto chama o processo de "envolver" os dados camada por camada ao descer pela pilha TCP/IP?',
        alternativas: ['Decapsulamento', 'Encapsulamento', 'Multiplexação', 'Roteamento'],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que a Camada de Transporte adiciona ao dividir a mensagem em segmentos?',
        alternativas: [
          'Endereços MAC e CRC',
          'Portas de origem/destino e números de sequência',
          'Sinais elétricos e ópticos',
          'Endereços IP de origem e destino',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'O que a Camada de Enlace adiciona ao pacote, formando um quadro?',
        alternativas: [
          'Endereços MAC válidos para o próximo salto e um código de verificação de erros (CRC)',
          'Portas de origem e destino',
          'O endereço IP de destino final',
          'O nome de domínio do destinatário',
        ],
        correta: 0,
      ),
      Pergunta(
        enunciado: 'No decapsulamento no destino, o que a Camada de Rede faz?',
        alternativas: [
          'Transforma sinais em bits',
          'Lê o endereço IP e, se for o destino final, extrai o segmento',
          'Reordena os segmentos pelos números de sequência',
          'Apresenta a mensagem final ao usuário',
        ],
        correta: 1,
      ),
      Pergunta(
        enunciado: 'Por que a internet funciona de forma confiável e escalável, segundo o texto?',
        alternativas: [
          'Porque uma única camada faz todo o trabalho sozinha',
          'Porque cada camada resolve um problema específico e bem delimitado, numa divisão de responsabilidades',
          'Porque o TTL elimina a necessidade de todas as outras camadas',
          'Porque o HTTP substitui todas as camadas inferiores',
        ],
        correta: 1,
      ),
    ],
  ),
};
