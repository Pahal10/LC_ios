// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Let\'s Connect';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get save => 'Guardar';

  @override
  String get copy => 'Copiar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get email => 'Correo electrónico';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get or => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get newHere => '¿Primera vez aquí?';

  @override
  String get register => 'Regístrate';

  @override
  String get signUp => 'Registrarse';

  @override
  String get loginEmptyFields => 'Escribe un nombre de usuario y una contraseña, o regístrate';

  @override
  String get loginInvalid => 'Nombre de usuario o contraseña incorrectos';

  @override
  String googleSignInFailed(String error) {
    return 'Error al iniciar sesión con Google: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Error al iniciar sesión con Apple: $error';
  }

  @override
  String get promoCodeOptional => 'Código promocional (opcional)';

  @override
  String get promoCodeTitle => 'Código promocional';

  @override
  String get promoCodeInfo => 'Si ingresas el código promocional de otro usuario al registrarte, ambos recibirán una Recompensa Premium en su correo registrado.';

  @override
  String get agreeCommunications => 'Acepto recibir comunicaciones de ustedes en este correo';

  @override
  String get agreeCommunicationsOccasional => 'Acepto recibir comunicaciones ocasionales de Let\'s Connect';

  @override
  String get invalidEmail => 'Ingresa un correo electrónico válido';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get mustAgreeCommunicationsEmail => 'Para registrarte, acepta recibir comunicaciones en tu correo';

  @override
  String get mustAgreeCommunications => 'Para continuar, acepta recibir comunicaciones';

  @override
  String get usernameExists => 'Ese nombre de usuario ya existe';

  @override
  String get emailRegistered => 'Ese correo ya está registrado';

  @override
  String get registrationSuccessful => 'Registro exitoso';

  @override
  String get invalidPromoCode => 'Código promocional no válido.';

  @override
  String get niceTry => 'Buen intento 😊';

  @override
  String get chooseUsername => 'Elige un nombre de usuario';

  @override
  String get locationServicesDisabled => 'Los servicios de ubicación están desactivados.';

  @override
  String get locationPermissionDenied => 'Permiso de ubicación denegado.';

  @override
  String get locationPermissionDeniedForever => 'Permiso de ubicación denegado permanentemente.';

  @override
  String get locationUpdated => 'Ubicación actualizada correctamente. Ya puedes desactivar los servicios de ubicación.';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get getStartedPrompt => 'Ingresa tu correo y te enviaremos un enlace para crear tu cuenta.';

  @override
  String get sending => 'Enviando...';

  @override
  String get enterYourEmail => 'Ingresa tu correo electrónico.';

  @override
  String get checkYourEmail => 'Revisa tu correo';

  @override
  String get getStartedEmailSent => 'Te enviamos un correo con el enlace para crear tu cuenta de Let\'s Connect.';

  @override
  String get couldntSendEmail => 'No se pudo enviar el correo';

  @override
  String get forgotPasswordTitle => 'Olvidé mi contraseña';

  @override
  String get forgotPasswordPrompt => 'Ingresa el correo vinculado a tu cuenta.';

  @override
  String get sendResetCode => 'Enviar código de restablecimiento';

  @override
  String get emailNotFound => 'Correo no encontrado';

  @override
  String get resetCodeSent => 'Código de restablecimiento enviado';

  @override
  String get passwordResetEmailSent => 'Correo para restablecer la contraseña enviado';

  @override
  String get verifyCodeTitle => 'Verificar código';

  @override
  String codeSentTo(String email) {
    return 'Se envió un código a\n$email';
  }

  @override
  String get resetCode => 'Código de restablecimiento';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get invalidCode => 'Código no válido';

  @override
  String get codeExpired => 'El código expiró';

  @override
  String get passwordUpdated => 'Contraseña actualizada';

  @override
  String get welcomeToLC => 'Te damos la bienvenida a Let\'s Connect';

  @override
  String get welcomeTagline => 'Elige una opción para que podamos ayudarte mejor.';

  @override
  String get wantToMakeFriends => 'Quiero hacer amigos';

  @override
  String get iFeelLonely => 'Me siento solo(a)';

  @override
  String get stageSmallTalk => 'Conversación Ligera';

  @override
  String get stageMediumTalk => 'Conversación Intermedia';

  @override
  String get stageBigTalk => 'Conversación Profunda';

  @override
  String get stageVoiceCall => 'Llamada de Voz';

  @override
  String get stagePlayDate => 'Hora de Jugar';

  @override
  String get stageHygge => 'Hygge';

  @override
  String get chooseAStage => 'Elige una etapa';

  @override
  String get taskDone => 'Listo';

  @override
  String get anotherTask => 'Otra tarea';

  @override
  String get shhInsiderInfo => 'Shh: información privilegiada';

  @override
  String get bigTalkInsightTitle => '💡 Dato de la Conversación Profunda';

  @override
  String get quickQuestion => 'Pregunta rápida';

  @override
  String get feelMoreConnected => '¿Te sientes más conectado(a) con otras personas?';

  @override
  String get comfortableQuestion => '¿Te sentiste cómodo(a) haciéndolo?';

  @override
  String get somewhat => 'Más o menos';

  @override
  String get couldntSendReward => 'No se pudo enviar la recompensa.';

  @override
  String get couldntSendVerifyLink => 'No se pudo enviar el enlace de verificación de la tarea.';

  @override
  String get welcomeTitle => 'Bienvenido(a)';

  @override
  String get introDialogBody => 'La soledad, o la dificultad para conectar con los demás, es un sentimiento, no una enfermedad. Por eso te ayudaremos como en un camino humano, y no como una pastilla que se toma todos los días. Esta app no es una herramienta mágica contra la soledad, sino una ayuda para superar ese sentimiento. Como descargaste la app, creo que podemos comenzar este camino. Empezaremos poco a poco, con conversaciones ligeras, como preguntarle la hora a alguien. Si no quieres hacer una tarea, toca \"Otra tarea\" y la app elegirá otra al azar. Esta opción es ilimitada, pero recuerda que el tiempo no lo es. Así que elige una y pruébala. Cuando termines, toca Listo para volver a la pantalla principal. Recuerda: no estás obligado(a) a hacer las tareas. Solo estamos aquí para ayudarte si lo necesitas :)';

  @override
  String get letsBegin => 'Empecemos';

  @override
  String get playDateIntroTitle => 'Te damos la bienvenida a la Hora de Jugar';

  @override
  String get playDateIntroBody => 'Hasta ahora, en este camino has practicado cómo iniciar conversaciones y crear conexiones con otras personas.\n\nConversar es poderoso porque nos ayuda a conocer las experiencias, los pensamientos y la historia de otra persona. Pero solo conversar no crea recuerdos compartidos.\n\nMuchas amistades se fortalecen con experiencias compartidas: jugar, hacer actividades juntos, explorar lugares nuevos o simplemente pasar tiempo juntos.\n\nEn esta etapa recibirás sugerencias de juegos y actividades para hacer con otras personas.\n\nSon solo recomendaciones. Nunca estás obligado(a) a jugar un juego en particular y siempre puedes elegir otra actividad que te resulte más cómoda o divertida.\n\nLa meta no es terminar un juego en específico, sino hacer bromas, molestarse con cariño y crear recuerdos.';

  @override
  String get hyggeIntroTitle => 'Te damos la bienvenida al Hygge';

  @override
  String get hyggeIntroBody => 'Desde hace varios años, los países escandinavos encabezan la lista de los países más felices del mundo. Puede haber distintas explicaciones, pero creemos que la cultura del Hygge (se pronuncia \"jú-ga\") es una de las razones.\nEl Hygge es un concepto danés que, en pocas palabras, significa tomarse un tiempo de la rutina para disfrutar de la calidez y la comodidad con amigos. No implica actividades específicas, sino rutinas sencillas, como tomar chocolate caliente y jugar juegos de mesa con una luz cálida.\n\nEn el Hygge, el ambiente de comodidad y calidez es más importante que la actividad en sí. Te daremos algunas sugerencias, pero también te aconsejamos crear tus propias rutinas y actividades.\n\nP.D. Esta es la forma máxima de conexión social.';

  @override
  String get bigTalkIntroTitle => 'Te damos la bienvenida a la Conversación Profunda';

  @override
  String get bigTalkIntroBody => 'Casi todos conocen la conversación ligera. Sin embargo, esta lleva a conexiones superficiales. Mientras más profundo llegamos en la vida de una persona, más conectados nos sentimos con ella. Partiendo de esta idea, una estudiante universitaria (Kalina Silverman) ideó una solución para la soledad y la nombró en contraste con la conversación ligera: la Conversación Profunda (Big Talk). En la siguiente sección recibirás propuestas que van más allá de las preguntas básicas. Te aconsejamos practicar estas conversaciones con alguien que ya conozcas (para sentirte cómodo(a) con la Conversación Profunda) y después probarlas con desconocidos. Otro consejo es mantener la conversación por al menos 5 minutos, porque sería incómodo, para la otra persona y para tu cerebro, hacer una pregunta profunda y terminar la conversación de golpe. Tu cerebro probablemente se bloqueará al pasar de una conexión profunda a cero de repente.\nPara mantener la conversación, puedes recordar temas de la conversación ligera o simplemente preguntar cosas relacionadas con la pregunta que acabas de hacer. Como siempre, si en algún momento sientes que no puedes, puedes abandonar, pero recuerda que la ansiedad y la duda de corto plazo no resolverán tu soledad a largo plazo.';

  @override
  String get congratulations => 'Felicidades 🎉';

  @override
  String get graduationBody => 'Este es el final de tu camino por las etapas guiadas. Empezaste con conversaciones ligeras y llegaste al medio máximo de conexión social: el Hygge. Si no lograste tu meta de conectar con otras personas o de sentirte menos solo(a), puedes escribirnos un correo y te ayudaremos directamente. Pero si te sientes menos solo(a) que antes (no pasa nada si no es cero), te aconsejamos seguir por este camino de mantener y construir conexiones. Lo sugerimos porque, si te detienes, tus conexiones sociales disminuirán, y un cerebro acostumbrado a tu nivel actual de conexión sentirá hambre social (es decir, soledad).\n\nNo te pedimos que sigas usando esta app, pero aún podemos ayudarte si necesitas ideas. A partir de ahora, el botón \"Vamos a conectarnos\" de tu pantalla principal abrirá una página con un botón para cada etapa que recorriste. Si lo necesitas, puedes elegir una etapa y tomar sugerencias de ahí.\n\nEn lugar de despedirnos, te haremos una pregunta de autorreflexión. ¿Te sientes menos solo(a) después de nuestra ayuda?';

  @override
  String get yesSmile => 'Sí :)';

  @override
  String get noSad => 'No :(';

  @override
  String get realityCheck1 => 'Por lo general, a las personas les gusta conversar con desconocidos más de lo que esperan.';

  @override
  String get realityCheck2 => 'Las personas esperan que solo el 40% de los desconocidos respondan de forma amable a una conversación espontánea, pero en realidad el 92% lo hace.';

  @override
  String get realityCheck3 => 'En el primer encuentro, le caes mejor a la gente de lo que crees.';

  @override
  String get realityCheck4 => 'La expectativa de una conversación suele dar más miedo que la conversación en sí.';

  @override
  String get realityCheck5 => 'Una conversación breve puede mejorar el ánimo de las dos personas.';

  @override
  String get realityCheck6 => 'Nunca sabes qué nueva forma de vivir descubrirás hoy. ¡Incluso podrías encontrarte con un filósofo de tiempo completo!';

  @override
  String get realityCheck7 => 'Las conexiones profundas empiezan con una conversación, y la conversación empieza acercándote a alguien un día cualquiera.';

  @override
  String get realityCheck8 => 'Una conexión no tiene que ser perfecta la primera vez que se conocen. Se ha visto que dos personas que se detestaban se vuelven mejores amigas.';

  @override
  String get realityCheck9 => 'Mucha gente espera que alguien le hable primero.';

  @override
  String get realityCheck10 => 'Cuando tenemos hambre y comida enfrente, comemos. La soledad es hambre social. Cuando tengas a una persona enfrente, date un mordisco del pastel social (tranquilo(a), no te estoy pidiendo que te comas a nadie).';

  @override
  String get realityCheck11 => 'La conversación ligera no es lo opuesto a la conexión. Muchas veces es la puerta de entrada.';

  @override
  String get realityCheck12 => 'La mayoría de las personas responde con amabilidad a preguntas sencillas y respetuosas.';

  @override
  String get bigTalkInsight1 => 'Las amistades significativas rara vez nacen solo de conversaciones ligeras.';

  @override
  String get bigTalkInsight2 => 'A la mayoría de las personas les gusta que les hagan preguntas reflexivas más de lo que pensamos.';

  @override
  String get bigTalkInsight3 => 'Mucha gente desearía que las conversaciones fueran más profundas, pero espera a que otra persona dé el primer paso.';

  @override
  String get bigTalkInsight4 => 'La vulnerabilidad suele fortalecer las relaciones en lugar de debilitarlas.';

  @override
  String get bigTalkInsight5 => 'Ser alguien interesado es más importante que ser alguien interesante.';

  @override
  String get bigTalkInsight6 => 'Las personas suelen recordar cómo se sintieron en una conversación, no si cada palabra fue perfecta.';

  @override
  String get bigTalkInsight7 => 'Una pregunta significativa puede crear más conexión que una hora de conversación casual.';

  @override
  String get bigTalkInsight8 => 'La mayoría de las personas agradece sentirse realmente escuchada.';

  @override
  String get bigTalkInsight9 => 'El objetivo de la Conversación Profunda es comprender, no impresionar.';

  @override
  String get bigTalkInsight10 => 'La conexión crece cuando las personas comparten experiencias, valores y perspectivas.';

  @override
  String get taskSmallTalk1 => 'Pregúntale a alguien qué hora es';

  @override
  String get taskSmallTalk2 => 'Pregúntale a alguien si hay un baño cerca';

  @override
  String get taskSmallTalk3 => 'Pídele a alguien indicaciones para llegar a una cafetería cercana';

  @override
  String get taskSmallTalk4 => 'Pregúntale a alguien si hay un cajero automático cerca';

  @override
  String get taskSmallTalk5 => 'Pregúntale a alguien qué día o qué fecha es hoy';

  @override
  String get taskMediumTalk1 => 'Elogia algún accesorio de alguien y pregúntale dónde lo consiguió';

  @override
  String get taskMediumTalk2 => 'Cuenta un recuerdo personal';

  @override
  String get taskBigTalk1 => 'Pregúntale a alguien cuál es su mayor miedo';

  @override
  String get taskBigTalk2 => 'Conversa con alguien sobre metas de vida';

  @override
  String get taskBigTalk3 => 'Si pudieras hacer la fiesta de tus sueños con presupuesto ilimitado, ¿cómo sería?';

  @override
  String get taskBigTalk4 => '¿Qué legado quieres dejar?';

  @override
  String get taskBigTalk5 => '¿Qué tradición de temporada esperas con ilusión cada año?';

  @override
  String get taskBigTalk6 => '¿Cuándo te sentiste más valiente en tu vida?';

  @override
  String get taskBigTalk7 => 'Si pudieras formar un equipo de 5 superhéroes para pelear a tu lado contra alienígenas, ¿quiénes serían?';

  @override
  String get taskBigTalk8 => 'Si fueras del género opuesto por un día, ¿cómo pasarías ese día?';

  @override
  String get taskBigTalk9 => 'Si pudieras cambiar tu país de nacimiento y vivir la vida de la gente de allá, ¿qué país elegirías y por qué?';

  @override
  String get taskBigTalk10 => 'Si pudieras recrear un recuerdo conmigo, ¿cuál elegirías recrear?';

  @override
  String get taskBigTalk11 => 'Si de pronto te dieran el trabajo de guionista de Netflix, ¿cuál sería tu primera historia?';

  @override
  String get taskBigTalk12 => '¿Cuál es una cicatriz no física de tu infancia que no has compartido conmigo?';

  @override
  String get taskVoiceCall1 => 'Llama a un amigo y hablen de los temas que quieras por al menos 5 minutos';

  @override
  String get taskPlayDate1 => 'Jueguen el juego de mesa de la Vida';

  @override
  String get taskPlayDate2 => 'Aprendan juntos un juego de cartas nuevo y jueguen';

  @override
  String get taskPlayDate3 => 'Jueguen un juego en línea juntos (menos recomendado, porque los juegos en persona crean más conexión)';

  @override
  String get taskPlayDate4 => 'Jueguen Monopoly';

  @override
  String get taskPlayDate5 => 'Jueguen Pictionary';

  @override
  String get taskPlayDate6 => 'Jueguen antakshari (no importa si no lo pronuncias bien; si no lo conoces, búscalo)';

  @override
  String get taskPlayDate7 => 'Jueguen a las charadas';

  @override
  String get taskPlayDate8 => 'Busquen juegos tipo \"Minute to Win It\"';

  @override
  String get taskPlayDate9 => 'Intenten coreografiar una canción juntos y graben un video de la versión final (y del detrás de cámaras, si quieren)';

  @override
  String get taskPlayDate10 => 'Jueguen fútbol o baloncesto';

  @override
  String get taskPlayDate11 => 'Jueguen Clue';

  @override
  String get taskHygge1 => 'Recuéstate en el sofá con un chocolate caliente (o una bebida fría) y ten una conversación profunda';

  @override
  String get taskHygge2 => 'Cocinen o estudien juntos con calma';

  @override
  String get taskHygge3 => 'Jueguen un juego de mesa juntos';

  @override
  String get taskHygge4 => 'Inicia una conversación intelectual sobre economía o sobre el mundo que te rodea';

  @override
  String get questionnaire => 'Cuestionario';

  @override
  String get whyLonely => '¿Por qué crees que te sientes solo(a)?';

  @override
  String get reasonCantTalk => 'No logro hablar con la gente ni hacer amigos';

  @override
  String get reasonMoved => 'Me mudé a un lugar nuevo sin la mayoría de mis amigos cercanos';

  @override
  String get reasonLoss => 'Perdí hace poco a alguien cercano, y eso dejó un vacío en mi red social';

  @override
  String get reasonNotUnderstood => 'Las personas a mi alrededor no me entienden';

  @override
  String get reasonOthers => 'Otros';

  @override
  String get misunderstoodTitle => 'La gente no me entiende';

  @override
  String get misunderstoodBody => 'Es un sentimiento difícil cuando la gente no te entiende...\n\nEsto puede ocurrir una o pocas veces, o con frecuencia/siempre. Si nos dices cuál es tu caso, podemos ayudarte.';

  @override
  String get onceFewTimes => 'Una o pocas veces';

  @override
  String get frequentlyAlways => 'Con frecuencia/Siempre';

  @override
  String get possibleReasonsTitle => 'Posibles razones';

  @override
  String get possibleReasonsBody => 'Si este problema ocurrió pocas veces, puede deberse a dos razones principales:\n\n1. Dificultad de la otra persona para entenderte, por diferencia de opinión, porque no estaba de humor, etc.\n\n2. Diferencias de idioma, de acento, etc. con la persona con la que hablaste.';

  @override
  String get twoOptionsBody => 'En ese caso tienes dos opciones.\n\n1. Intentar explicárselo de nuevo\n\n2. Encontrar personas nuevas que posiblemente te entiendan.';

  @override
  String get explainAgain => 'Intentaré explicarlo de nuevo';

  @override
  String get helpFindConnections => 'Ayúdame a encontrar nuevas conexiones';

  @override
  String get noDirectHelpBody => 'No tenemos ayuda directa dentro de la app para eso, pero puedes probar traductores o apps para mejorar el acento.\n\nTe sugerimos algunas plataformas abajo para orientarte :)';

  @override
  String get whichIsTrue => '¿Cuál de las siguientes opciones es cierta?';

  @override
  String get particularGroup => 'Con un grupo particular de personas';

  @override
  String get withEveryone => 'Con todos';

  @override
  String get newConnectionsTitle => 'Nuevas conexiones';

  @override
  String get newConnectionsBody => 'A veces las diferencias entre las personas son tan grandes que las conexiones no se forman bien.\n\nEn ese caso, lo mejor es seguir adelante y buscar nuevas conexiones.\n\n¿Quieres hacer nuevas conexiones?';

  @override
  String get yesLetsConnect => '¡Sí! Vamos a conectarnos';

  @override
  String get noTryExplainingAgain => 'No. Quiero intentar explicárselos una vez más';

  @override
  String get othersDialogTitle => 'No pasa nada si ninguna de las opciones te describe :)';

  @override
  String get othersDialogBody => 'Escribe a pahal.bhatti11@gmail.com para compartir lo que piensas sobre por qué te sientes solo(a) y recibir ayuda personalizada.';

  @override
  String get movingTitle => 'Mudarse a una nueva ciudad';

  @override
  String get movingBody => 'Cuando nos mudamos a un lugar nuevo, cambian muchas cosas. Una de ellas son nuestras conexiones sociales. Si no logramos equilibrar nuestras conexiones sociales con nuestra hambre social, empezamos a sentirnos solos. Es algo muy normal y le pasa a casi cualquiera que se muda a un lugar nuevo.\n\n¿Cómo lo enfrentamos? Básicamente hay dos opciones. Primero, intentar conservar las relaciones que tenemos en casa. Segundo, hacer amigos nuevos de inmediato y estar tan cerca de ellos como estábamos de nuestros amigos de allá. Al reflexionar sobre estas opciones, te das cuenta de que ninguna es perfectamente posible (las conexiones en línea con los amigos de casa no bastan, y hacer amigos al instante no es realista).\n\nAsí que lo mejor es combinar ambas: mantener el contacto con tus amigos cercanos de casa e intentar hacer amigos nuevos. Podemos ofrecerte recordatorios para lo primero y ayudarte con lo segundo después de que elijas una de las siguientes opciones.';

  @override
  String get canTalkToStrangers => 'Puedo hablar con desconocidos (por ejemplo, iniciar una conversación con la persona que está a mi lado en el metro o charlar en un elevador)';

  @override
  String get socialAnxiety => 'Tengo ansiedad social y no me siento cómodo(a) saliendo a hablar con desconocidos.';

  @override
  String get lossTitle => 'Pérdida y soledad';

  @override
  String get lossBody => 'Lamento muchísimo oír eso…\n\nComo seres humanos, necesitamos tiempo para superar nuestras pérdidas. Por eso te animamos a sentarte, reflexionar sobre lo que sientes (con ayuda profesional si es necesario) y decidir si estás triste o si sientes soledad.\n\nSi crees que estás triste y necesitas tiempo para seguir adelante, podemos esperar hasta entonces :)\n\nPero si te sientes solo(a), quizá podamos ayudarte. Esto no será una dosis rápida de medicina, sino un esfuerzo sostenido de tu parte que va sanando poco a poco tu alma herida. Estaremos aquí como guía en tu camino.\n\nPrimero lo básico. Para dejar de sentirnos solos, necesitamos conectar con personas nuevas para saciar nuestra hambre social. La meta no es reemplazar a quienes perdiste, sino construir una nueva red de conexiones. Para empezar, elige una de las siguientes opciones.';

  @override
  String get nextTask => 'Siguiente tarea';

  @override
  String get letsConnectButton => 'Vamos a conectarnos';

  @override
  String get uclaScoreTest => 'Prueba de soledad\nde la UCLA';

  @override
  String welcomeUser(String username) {
    return 'Te damos la bienvenida, $username.\n¿Qué te gustaría hacer hoy?';
  }

  @override
  String get accountSettings => 'Configuración de la cuenta';

  @override
  String get accountSettingsPrompt => '¿Qué te gustaría cambiar?';

  @override
  String get changeUsername => 'Cambiar nombre de usuario';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get chooseDifferentReason => 'Elegir otra razón';

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get contactBody => '¿Tienes comentarios, quieres reportar problemas o solo necesitas a alguien con quien hablar?\n\nCorreo:\npahal.bhatti11@gmail.com';

  @override
  String get updateLocation => 'Actualizar ubicación';

  @override
  String get updateLocationSubtitle => 'Solo se necesita para verificar recompensas';

  @override
  String get rateThisApp => 'Calificar la app';

  @override
  String get myPromoCode => 'Mi código promocional';

  @override
  String get myPromoCodeTitle => 'Mi código promocional';

  @override
  String get myPromoCodeBody => 'Al registrarse, si un nuevo usuario ingresa tu código promocional, ambos recibirán una Recompensa Premium.';

  @override
  String get promoCodeCopied => 'Código promocional copiado.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirm => '¿Seguro que quieres eliminar tu cuenta de forma permanente?';

  @override
  String get logoutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String get uclaScaleTitle => 'Escala de Soledad de la UCLA';

  @override
  String get uclaScalePopupBody => 'La Escala de Soledad de la UCLA (UCLA Loneliness Scale) está disponible en línea. Copia y pega este enlace en tu navegador favorito\nhttps://backend.fetzer.org/sites/default/files/images/stories/pdf/selfmeasures/Self_Measures_for_Love_and_Compassion_Research_LONELINESS_AND_INTERPERSONAL_PROBLEMS.pdf';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newUsername => 'Nuevo nombre de usuario';

  @override
  String get incorrectPassword => 'Contraseña incorrecta';

  @override
  String get usernameUpdated => 'Nombre de usuario actualizado';

  @override
  String get changeReasonTitle => '¿Cambiar la razón?';

  @override
  String get changeReasonBody => 'Puedes volver a hacer el cuestionario de soledad y elegir otra razón. Básicamente volverás a la página donde respondiste la pregunta \"¿Por qué crees que te sientes solo(a)?\".';

  @override
  String get uclaTestTitle => 'Prueba de la UCLA';

  @override
  String scoreSaved(int score) {
    return 'Puntuación guardada: $score';
  }
}
