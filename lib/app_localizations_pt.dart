// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Let\'s Connect';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get save => 'Salvar';

  @override
  String get copy => 'Copiar';

  @override
  String get logout => 'Sair';

  @override
  String errorWithDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String get username => 'Nome de usuário';

  @override
  String get password => 'Senha';

  @override
  String get email => 'E-mail';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get logIn => 'Entrar';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get newHere => 'Novo por aqui?';

  @override
  String get register => 'Cadastre-se';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get loginEmptyFields => 'Digite um nome de usuário e uma senha, ou cadastre-se';

  @override
  String get loginInvalid => 'Nome de usuário ou senha inválidos';

  @override
  String googleSignInFailed(String error) {
    return 'Falha ao entrar com o Google: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Falha ao entrar com a Apple: $error';
  }

  @override
  String get promoCodeOptional => 'Código promocional (opcional)';

  @override
  String get promoCodeTitle => 'Código promocional';

  @override
  String get promoCodeInfo => 'Se você inserir o código promocional de outro usuário durante o cadastro, vocês dois receberão uma Recompensa Premium no e-mail cadastrado.';

  @override
  String get agreeCommunications => 'Concordo em receber comunicações de vocês neste e-mail';

  @override
  String get agreeCommunicationsOccasional => 'Concordo em receber comunicações ocasionais do Let\'s Connect';

  @override
  String get invalidEmail => 'Digite um e-mail válido';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get mustAgreeCommunicationsEmail => 'Para se cadastrar, concorde em receber comunicações no seu e-mail';

  @override
  String get mustAgreeCommunications => 'Para continuar, concorde em receber comunicações';

  @override
  String get usernameExists => 'Este nome de usuário já existe';

  @override
  String get emailRegistered => 'Este e-mail já está cadastrado';

  @override
  String get registrationSuccessful => 'Cadastro realizado com sucesso';

  @override
  String get invalidPromoCode => 'Código promocional inválido.';

  @override
  String get niceTry => 'Boa tentativa 😊';

  @override
  String get chooseUsername => 'Escolha um nome de usuário';

  @override
  String get locationServicesDisabled => 'Os serviços de localização estão desativados.';

  @override
  String get locationPermissionDenied => 'Permissão de localização negada.';

  @override
  String get locationPermissionDeniedForever => 'Permissão de localização negada permanentemente.';

  @override
  String get locationUpdated => 'Localização atualizada com sucesso. Você já pode desativar os serviços de localização.';

  @override
  String get getStarted => 'Começar';

  @override
  String get getStartedPrompt => 'Digite seu e-mail e enviaremos um link para você criar sua conta.';

  @override
  String get sending => 'Enviando...';

  @override
  String get enterYourEmail => 'Digite seu e-mail.';

  @override
  String get checkYourEmail => 'Verifique seu e-mail';

  @override
  String get getStartedEmailSent => 'Enviamos um e-mail com o link para você criar sua conta no Let\'s Connect.';

  @override
  String get couldntSendEmail => 'Não foi possível enviar o e-mail';

  @override
  String get forgotPasswordTitle => 'Esqueci a senha';

  @override
  String get forgotPasswordPrompt => 'Digite o e-mail vinculado à sua conta.';

  @override
  String get sendResetCode => 'Enviar código de redefinição';

  @override
  String get emailNotFound => 'E-mail não encontrado';

  @override
  String get resetCodeSent => 'Código de redefinição enviado';

  @override
  String get passwordResetEmailSent => 'E-mail de redefinição de senha enviado';

  @override
  String get verifyCodeTitle => 'Verificar código';

  @override
  String codeSentTo(String email) {
    return 'Um código foi enviado para\n$email';
  }

  @override
  String get resetCode => 'Código de redefinição';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get resetPassword => 'Redefinir senha';

  @override
  String get invalidCode => 'Código inválido';

  @override
  String get codeExpired => 'Código expirado';

  @override
  String get passwordUpdated => 'Senha atualizada';

  @override
  String get welcomeToLC => 'Bem-vindo(a) ao Let\'s Connect';

  @override
  String get welcomeTagline => 'Escolha uma opção abaixo para que possamos ajudar você melhor.';

  @override
  String get wantToMakeFriends => 'Quero fazer amigos';

  @override
  String get iFeelLonely => 'Me sinto sozinho(a)';

  @override
  String get stageSmallTalk => 'Conversa Leve';

  @override
  String get stageMediumTalk => 'Conversa Média';

  @override
  String get stageBigTalk => 'Conversa Profunda';

  @override
  String get stageVoiceCall => 'Chamada de Voz';

  @override
  String get stagePlayDate => 'Hora de Jogar';

  @override
  String get stageHygge => 'Hygge';

  @override
  String get chooseAStage => 'Escolha uma etapa';

  @override
  String get taskDone => 'Concluído';

  @override
  String get anotherTask => 'Outra tarefa';

  @override
  String get shhInsiderInfo => 'Psiu: informação de bastidores';

  @override
  String get bigTalkInsightTitle => '💡 Dica da Conversa Profunda';

  @override
  String get quickQuestion => 'Pergunta rápida';

  @override
  String get feelMoreConnected => 'Você se sente mais conectado(a) com as outras pessoas?';

  @override
  String get comfortableQuestion => 'Você se sentiu confortável fazendo isso?';

  @override
  String get somewhat => 'Mais ou menos';

  @override
  String get couldntSendReward => 'Não foi possível enviar a recompensa.';

  @override
  String get couldntSendVerifyLink => 'Não foi possível enviar o link de verificação da tarefa.';

  @override
  String get welcomeTitle => 'Bem-vindo(a)';

  @override
  String get introDialogBody => 'A solidão, ou a dificuldade de se conectar com os outros, é um sentimento, não uma doença. Por isso, vamos ajudar você como uma jornada humana, e não como um comprimido que se toma todo dia. Este app não é uma ferramenta mágica contra a solidão, e sim um apoio para superar esse sentimento. Como você baixou o app, acho que podemos começar essa jornada. Vamos começar devagar, com conversas leves, como perguntar a alguém que horas são. Se não quiser fazer uma tarefa, toque em \"Outra tarefa\" e o app vai escolher outra aleatoriamente. Essa opção é ilimitada, mas lembre-se: o tempo não é. Então escolha uma e experimente. Quando terminar, toque em Concluído para voltar à tela principal. Lembre-se: você não é obrigado(a) a fazer as tarefas. Estamos aqui só para ajudar, se você precisar :)';

  @override
  String get letsBegin => 'Vamos começar';

  @override
  String get playDateIntroTitle => 'Bem-vindo(a) à Hora de Jogar';

  @override
  String get playDateIntroBody => 'Até aqui nesta jornada, você praticou puxar conversa e criar conexões com outras pessoas.\n\nConversar é poderoso porque nos ajuda a conhecer as experiências, os pensamentos e a história de outra pessoa. Mas só conversar não cria memórias compartilhadas.\n\nMuitas amizades ficam mais fortes por meio de experiências em comum: jogar, fazer atividades juntos, explorar lugares novos ou simplesmente passar tempo juntos.\n\nNesta etapa, você vai receber sugestões de jogos e atividades para fazer com outras pessoas.\n\nSão apenas recomendações. Você nunca é obrigado(a) a jogar um jogo específico e pode sempre escolher outra atividade que seja mais confortável ou divertida para você.\n\nO objetivo não é terminar um jogo específico, e sim fazer piadas, se provocar de brincadeira e criar memórias.';

  @override
  String get hyggeIntroTitle => 'Bem-vindo(a) ao Hygge';

  @override
  String get hyggeIntroBody => 'Há vários anos, os países escandinavos lideram a lista dos países mais felizes do mundo. Pode haver várias explicações, mas acreditamos que a cultura do Hygge (pronuncia-se \"hu-gue\") é um dos motivos.\nHygge é um conceito dinamarquês que, resumindo, significa reservar um tempo da sua rotina corrida para o aconchego e o conforto com os amigos. Não envolve atividades específicas, e sim rotinas simples, como tomar chocolate quente e jogar jogos de tabuleiro sob uma luz acolhedora.\n\nNo Hygge, o ambiente de conforto e aconchego é mais importante do que a atividade em si. Vamos dar algumas sugestões, mas também aconselhamos que você crie suas próprias rotinas e atividades.\n\nP.S. Esta é a forma máxima de conexão social.';

  @override
  String get bigTalkIntroTitle => 'Bem-vindo(a) à Conversa Profunda';

  @override
  String get bigTalkIntroBody => 'Quase todo mundo conhece a conversa leve. Porém, ela leva a conexões superficiais. Quanto mais fundo vamos na vida de uma pessoa, mais conectados nos sentimos com ela. A partir dessa ideia, uma estudante de graduação (Kalina Silverman) criou uma solução para a solidão e a batizou em contraste com a conversa leve: a Conversa Profunda (Big Talk). Na próxima seção, você vai receber propostas que vão além das perguntas básicas. Aconselhamos que você pratique essas conversas com alguém que já conhece (para se sentir à vontade com a Conversa Profunda) e depois experimente com desconhecidos. Outra dica é manter a conversa por pelo menos 5 minutos, porque seria estranho, para a outra pessoa e para o seu cérebro, fazer uma pergunta profunda e encerrar a conversa de repente. Seu cérebro provavelmente vai travar ao passar de uma conexão profunda para o zero.\nPara manter a conversa, você pode lembrar dos assuntos da conversa leve ou simplesmente perguntar outras coisas relacionadas à pergunta que acabou de fazer. Como sempre, se em algum momento sentir que não consegue, você pode desistir, mas lembre-se: a ansiedade e a dúvida de curto prazo não vão resolver a sua solidão de longo prazo.';

  @override
  String get congratulations => 'Parabéns 🎉';

  @override
  String get graduationBody => 'Este é o fim da sua jornada pelas etapas guiadas. Você começou com conversas leves e chegou ao meio máximo de conexão social: o Hygge. Se o seu objetivo de se conectar com outras pessoas ou de se sentir menos sozinho(a) não foi alcançado, você pode nos escrever um e-mail e podemos ajudar diretamente. Mas, se você se sente menos sozinho(a) do que antes (não tem problema se não for zero), aconselhamos que continue nesse caminho de manter e construir conexões. Sugerimos isso porque, se você parar, suas conexões sociais vão diminuir, e um cérebro acostumado ao seu nível atual de conexão vai sentir fome social (ou seja, solidão).\n\nNão pedimos que você continue usando o app, mas ainda podemos ajudar se precisar de ideias. A partir de agora, o botão \"Vamos nos conectar\" da tela principal vai abrir uma página com um botão para cada etapa pela qual você passou. Se precisar, você pode escolher uma etapa e pegar sugestões de lá.\n\nEm vez de dizer adeus, vamos fazer uma pergunta de autorreflexão. Você se sente menos sozinho(a) depois da nossa ajuda?';

  @override
  String get yesSmile => 'Sim :)';

  @override
  String get noSad => 'Não :(';

  @override
  String get realityCheck1 => 'As pessoas costumam gostar mais de conversar com desconhecidos do que esperam.';

  @override
  String get realityCheck2 => 'As pessoas esperam que apenas 40% dos desconhecidos respondam de forma amigável a uma conversa espontânea, mas na verdade 92% respondem.';

  @override
  String get realityCheck3 => 'No primeiro encontro, as pessoas gostam mais de você do que você imagina.';

  @override
  String get realityCheck4 => 'A expectativa de uma conversa costuma ser mais assustadora do que a conversa em si.';

  @override
  String get realityCheck5 => 'Uma conversa rápida pode melhorar o humor das duas pessoas.';

  @override
  String get realityCheck6 => 'Você nunca sabe que novo jeito de viver vai descobrir hoje. Quem sabe até encontre um filósofo em tempo integral!';

  @override
  String get realityCheck7 => 'As conexões profundas começam com uma conversa, e a conversa começa com uma aproximação num dia qualquer.';

  @override
  String get realityCheck8 => 'A conexão não precisa ser perfeita no primeiro encontro. Já se viu duas pessoas que se detestavam virarem melhores amigas.';

  @override
  String get realityCheck9 => 'Muita gente espera que alguém puxe conversa primeiro.';

  @override
  String get realityCheck10 => 'Quando estamos com fome e temos comida na frente, a gente come. A solidão é fome social. Quando você encontrar alguém na sua frente, dê uma mordida na torta social (calma, não estou pedindo para você comer ninguém).';

  @override
  String get realityCheck11 => 'Conversa leve não é o oposto de conexão. Muitas vezes é a porta de entrada.';

  @override
  String get realityCheck12 => 'A maioria das pessoas responde com gentileza a perguntas simples e respeitosas.';

  @override
  String get bigTalkInsight1 => 'Amizades significativas raramente nascem só de conversa leve.';

  @override
  String get bigTalkInsight2 => 'A maioria das pessoas gosta de receber perguntas ponderadas mais do que imaginamos.';

  @override
  String get bigTalkInsight3 => 'Muita gente gostaria que as conversas fossem mais profundas, mas está esperando que outra pessoa dê o primeiro passo.';

  @override
  String get bigTalkInsight4 => 'A vulnerabilidade costuma fortalecer os relacionamentos, e não enfraquecê-los.';

  @override
  String get bigTalkInsight5 => 'Ser interessado é mais importante do que ser interessante.';

  @override
  String get bigTalkInsight6 => 'As pessoas costumam lembrar de como a conversa fez com que se sentissem, e não se cada palavra foi perfeita.';

  @override
  String get bigTalkInsight7 => 'Uma pergunta significativa pode criar mais conexão do que uma hora de conversa casual.';

  @override
  String get bigTalkInsight8 => 'A maioria das pessoas gosta de sentir que está sendo realmente ouvida.';

  @override
  String get bigTalkInsight9 => 'O objetivo da Conversa Profunda é entender, não impressionar.';

  @override
  String get bigTalkInsight10 => 'A conexão cresce quando as pessoas compartilham experiências, valores e perspectivas.';

  @override
  String get taskSmallTalk1 => 'Pergunte a alguém que horas são';

  @override
  String get taskSmallTalk2 => 'Pergunte a alguém se há um banheiro por perto';

  @override
  String get taskSmallTalk3 => 'Peça a alguém indicações de uma cafeteria próxima';

  @override
  String get taskSmallTalk4 => 'Pergunte a alguém se há um caixa eletrônico por perto';

  @override
  String get taskSmallTalk5 => 'Pergunte a alguém que dia ou data é hoje';

  @override
  String get taskMediumTalk1 => 'Elogie um acessório de alguém e pergunte onde a pessoa comprou';

  @override
  String get taskMediumTalk2 => 'Conte uma lembrança pessoal';

  @override
  String get taskBigTalk1 => 'Pergunte a alguém qual é o seu maior medo';

  @override
  String get taskBigTalk2 => 'Converse com alguém sobre objetivos de vida';

  @override
  String get taskBigTalk3 => 'Se você pudesse dar a festa dos seus sonhos com orçamento ilimitado, como ela seria?';

  @override
  String get taskBigTalk4 => 'Que legado você quer deixar?';

  @override
  String get taskBigTalk5 => 'Qual tradição de uma época do ano você espera com ansiedade todo ano?';

  @override
  String get taskBigTalk6 => 'Em que momento da sua vida você se sentiu mais corajoso(a)?';

  @override
  String get taskBigTalk7 => 'Se você pudesse montar uma equipe de 5 super-heróis para lutar ao seu lado contra alienígenas, quem seriam?';

  @override
  String get taskBigTalk8 => 'Se você fosse do gênero oposto por um dia, como passaria esse dia?';

  @override
  String get taskBigTalk9 => 'Se você pudesse mudar seu país de nascimento e viver a vida das pessoas de lá, qual país escolheria e por quê?';

  @override
  String get taskBigTalk10 => 'Se você pudesse recriar uma lembrança comigo, qual escolheria recriar?';

  @override
  String get taskBigTalk11 => 'Se você de repente virasse roteirista da Netflix, qual seria a sua primeira história?';

  @override
  String get taskBigTalk12 => 'Qual é uma cicatriz não física da sua infância que você ainda não compartilhou comigo?';

  @override
  String get taskVoiceCall1 => 'Ligue para um amigo e converse sobre os assuntos que quiser por pelo menos 5 minutos';

  @override
  String get taskPlayDate1 => 'Joguem o jogo de tabuleiro Jogo da Vida';

  @override
  String get taskPlayDate2 => 'Aprendam um novo jogo de cartas juntos e joguem';

  @override
  String get taskPlayDate3 => 'Joguem um jogo online juntos (menos recomendado, porque jogos presenciais criam mais conexão)';

  @override
  String get taskPlayDate4 => 'Joguem Monopoly';

  @override
  String get taskPlayDate5 => 'Joguem Pictionary';

  @override
  String get taskPlayDate6 => 'Joguem antakshari (não tem problema se não pronunciar direito; se não conhece, pesquise)';

  @override
  String get taskPlayDate7 => 'Joguem mímica';

  @override
  String get taskPlayDate8 => 'Pesquisem jogos do tipo \"Minute to Win It\"';

  @override
  String get taskPlayDate9 => 'Tentem criar uma coreografia juntos para uma música e gravem um vídeo da versão final (e dos bastidores, se quiserem)';

  @override
  String get taskPlayDate10 => 'Joguem futebol ou basquete';

  @override
  String get taskPlayDate11 => 'Joguem Detetive';

  @override
  String get taskHygge1 => 'Deite no sofá com um chocolate quente (ou uma bebida gelada) e tenha uma conversa profunda';

  @override
  String get taskHygge2 => 'Cozinhem ou estudem juntos com calma';

  @override
  String get taskHygge3 => 'Joguem um jogo de tabuleiro juntos';

  @override
  String get taskHygge4 => 'Comece uma conversa intelectual sobre economia ou sobre o mundo ao redor';

  @override
  String get questionnaire => 'Questionário';

  @override
  String get whyLonely => 'Por que você acha que se sente sozinho(a)?';

  @override
  String get reasonCantTalk => 'Não consigo conversar com as pessoas ou fazer amigos';

  @override
  String get reasonMoved => 'Me mudei para um lugar novo e estou longe da maioria dos meus amigos próximos';

  @override
  String get reasonLoss => 'Perdi recentemente alguém próximo, e isso deixou um vazio na minha rede social';

  @override
  String get reasonNotUnderstood => 'As pessoas ao meu redor não me entendem';

  @override
  String get reasonOthers => 'Outros';

  @override
  String get misunderstoodTitle => 'As pessoas não me entendem';

  @override
  String get misunderstoodBody => 'É um sentimento difícil quando as pessoas não entendem você...\n\nIsso pode acontecer uma ou poucas vezes, ou com frequência/sempre. Se você nos disser qual é o seu caso, podemos ajudar.';

  @override
  String get onceFewTimes => 'Uma ou poucas vezes';

  @override
  String get frequentlyAlways => 'Com frequência/Sempre';

  @override
  String get possibleReasonsTitle => 'Possíveis motivos';

  @override
  String get possibleReasonsBody => 'Se esse problema aconteceu poucas vezes, pode ser por dois motivos principais:\n\n1. Dificuldade da outra pessoa em entender você, por diferença de opinião, humor do momento, etc.\n\n2. Diferenças de idioma, de sotaque, etc. com a pessoa com quem você conversou.';

  @override
  String get twoOptionsBody => 'Nesse caso, você tem duas opções.\n\n1. Tentar explicar de novo\n\n2. Encontrar novas pessoas que possam entender você.';

  @override
  String get explainAgain => 'Vou tentar explicar de novo';

  @override
  String get helpFindConnections => 'Me ajude a encontrar novas conexões';

  @override
  String get noDirectHelpBody => 'Não temos ajuda direta no app para isso, mas você pode tentar tradutores ou aplicativos de sotaque.\n\nSugerimos algumas plataformas abaixo para orientar você :)';

  @override
  String get whichIsTrue => 'Qual das opções a seguir é verdadeira?';

  @override
  String get particularGroup => 'Com um grupo específico de pessoas';

  @override
  String get withEveryone => 'Com todo mundo';

  @override
  String get newConnectionsTitle => 'Novas conexões';

  @override
  String get newConnectionsBody => 'Às vezes as diferenças entre as pessoas são tão grandes que as conexões não se formam bem.\n\nNesse caso, o melhor é seguir em frente e buscar novas conexões.\n\nVocê quer fazer novas conexões?';

  @override
  String get yesLetsConnect => 'Sim! Vamos nos conectar';

  @override
  String get noTryExplainingAgain => 'Não. Quero tentar explicar mais uma vez';

  @override
  String get othersDialogTitle => 'Tudo bem se nenhuma das opções combinar com você :)';

  @override
  String get othersDialogBody => 'Envie um e-mail para pahal.bhatti11@gmail.com para compartilhar o que você pensa sobre por que se sente sozinho(a) e receber ajuda personalizada.';

  @override
  String get movingTitle => 'Mudança para uma nova cidade';

  @override
  String get movingBody => 'Quando nos mudamos para um lugar novo, muita coisa muda. Uma delas são as nossas conexões sociais. Se não conseguimos equilibrar nossas conexões sociais com a nossa fome social, começamos a nos sentir sozinhos. Isso é muito normal e acontece com quase todo mundo que se muda para um lugar novo.\n\nComo lidar com isso? Basicamente, há duas opções. Primeiro, tentar manter os relacionamentos que temos em casa. Segundo, fazer novos amigos rapidamente e ser tão próximo deles quanto éramos dos amigos de lá. Ao refletir sobre essas opções, você percebe que nenhuma delas é totalmente possível (conexões online com os amigos de casa não bastam, e fazer amigos instantaneamente não é realista).\n\nPor isso, o melhor é combinar as duas: continuar em contato com seus amigos próximos de casa e tentar fazer novos amigos. Podemos oferecer lembretes para a primeira parte e ajudar com a segunda depois que você escolher uma das opções a seguir.';

  @override
  String get canTalkToStrangers => 'Consigo conversar com desconhecidos (por exemplo, puxar assunto com a pessoa ao meu lado no metrô ou bater papo no elevador)';

  @override
  String get socialAnxiety => 'Tenho ansiedade social e não me sinto confortável saindo para conversar com desconhecidos.';

  @override
  String get lossTitle => 'Perda e solidão';

  @override
  String get lossBody => 'Sinto muitíssimo por isso…\n\nComo seres humanos, precisamos de tempo para superar nossas perdas. Por isso, incentivamos você a parar, refletir sobre o que sente (com ajuda profissional, se necessário) e decidir se está triste ou se sente solidão.\n\nSe você acha que está triste e precisa de tempo para seguir em frente, podemos esperar até lá :)\n\nMas, se você se sente sozinho(a), talvez possamos ajudar. Isso não será uma dose rápida de remédio, e sim um esforço contínuo seu que cura aos poucos a sua alma ferida. Estaremos aqui como guia na sua jornada.\n\nPrimeiro o básico. Para deixar de se sentir sozinho(a), precisamos nos conectar com novas pessoas para saciar nossa fome social. O objetivo não é substituir quem você perdeu, e sim construir uma nova rede de conexões. Para começar, escolha uma das opções a seguir.';

  @override
  String get nextTask => 'Próxima tarefa';

  @override
  String get letsConnectButton => 'Vamos nos conectar';

  @override
  String get uclaScoreTest => 'Teste de solidão\nda UCLA';

  @override
  String welcomeUser(String username) {
    return 'Bem-vindo(a), $username,\nO que você gostaria de fazer hoje?';
  }

  @override
  String get accountSettings => 'Configurações da conta';

  @override
  String get accountSettingsPrompt => 'O que você gostaria de alterar?';

  @override
  String get changeUsername => 'Alterar nome de usuário';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get chooseDifferentReason => 'Escolher outro motivo';

  @override
  String get contactUs => 'Fale conosco';

  @override
  String get contactBody => 'Tem algum feedback, quer relatar problemas ou só precisa de alguém para conversar?\n\nE-mail:\npahal.bhatti11@gmail.com';

  @override
  String get updateLocation => 'Atualizar localização';

  @override
  String get updateLocationSubtitle => 'Necessária apenas para verificar recompensas';

  @override
  String get rateThisApp => 'Avaliar o app';

  @override
  String get myPromoCode => 'Meu código promocional';

  @override
  String get myPromoCodeTitle => 'Meu código promocional';

  @override
  String get myPromoCodeBody => 'Ao se cadastrar, se um novo usuário inserir o seu código promocional, vocês dois receberão uma Recompensa Premium.';

  @override
  String get promoCodeCopied => 'Código promocional copiado.';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAccountConfirm => 'Tem certeza de que deseja excluir sua conta permanentemente?';

  @override
  String get logoutConfirm => 'Tem certeza de que deseja sair?';

  @override
  String get uclaScaleTitle => 'Escala de Solidão da UCLA';

  @override
  String get uclaScalePopupBody => 'A Escala de Solidão da UCLA (UCLA Loneliness Scale) está disponível online. Copie e cole este link no seu navegador favorito\nhttps://backend.fetzer.org/sites/default/files/images/stories/pdf/selfmeasures/Self_Measures_for_Love_and_Compassion_Research_LONELINESS_AND_INTERPERSONAL_PROBLEMS.pdf';

  @override
  String get currentPassword => 'Senha atual';

  @override
  String get newUsername => 'Novo nome de usuário';

  @override
  String get incorrectPassword => 'Senha incorreta';

  @override
  String get usernameUpdated => 'Nome de usuário atualizado';

  @override
  String get changeReasonTitle => 'Alterar motivo?';

  @override
  String get changeReasonBody => 'Você pode refazer o questionário de solidão e escolher outro motivo. Basicamente, você voltará à página em que respondeu à pergunta \"Por que você acha que se sente sozinho(a)?\".';

  @override
  String get uclaTestTitle => 'Teste da UCLA';

  @override
  String scoreSaved(int score) {
    return 'Pontuação salva: $score';
  }
}
