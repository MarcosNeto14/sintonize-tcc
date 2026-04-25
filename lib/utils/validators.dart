/// Classe utilitária que agrega funções de validação e formatação
/// extraídas de várias telas do projeto.
///
/// IMPORTANTE: a lógica foi copiada EXATAMENTE como está nos arquivos
/// originais, preservando inconsistências entre implementações. Essas
/// inconsistências serão analisadas no TCC e NÃO devem ser corrigidas aqui.
class Validators {
  /// Origem: lib/cadastro.dart (_validateDate)
  /// Valida data de nascimento no formato dd/mm/aaaa.
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  }

  /// Origem: lib/cadastro.dart (_validateEmail)
  /// Campo OBRIGATÓRIO. Regex estrita: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
  ///
  /// INCONSISTÊNCIA: existem três validadores de e-mail no projeto com
  /// comportamentos diferentes — validateEmail (cadastro, obrigatório, regex
  /// estrita), validateEmailLogin (login, obrigatório, regex permissiva
  /// ^[^@]+@[^@]+\.[^@]+) e validateEmailEdit (alterar-dados, opcional, mesma
  /// regex estrita do cadastro). As mensagens de erro também divergem.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  /// Origem: lib/cadastro.dart (_validateCEP)
  /// Valida CEP no formato XXXXX-XXX.
  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  }

  /// Origem: lib/cadastro.dart (_validateNumero)
  /// Valida que o número do endereço é inteiro.
  static String? validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  }

  /// Origem: lib/cadastro.dart (validator inline do campo Nome)
  /// Rejeita números e caracteres especiais; aceita letras acentuadas e espaços.
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    final hasInvalidCharacters = RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
    if (hasInvalidCharacters) {
      return 'O nome não pode conter números ou caracteres especiais';
    }
    return null;
  }

  /// Origem: lib/login.dart (validator inline do TextFormField de email)
  /// Campo OBRIGATÓRIO. Regex PERMISSIVA: ^[^@]+@[^@]+\.[^@]+
  ///
  /// INCONSISTÊNCIA: diverge de validateEmail (cadastro) e validateEmailEdit
  /// (alterar-dados) — aqui a regex aceita quase qualquer coisa com um "@" e
  /// um ponto, enquanto os outros dois usam uma regex estrita.
  static String? validateEmailLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  /// Origem: lib/login.dart (validator inline do TextFormField de senha)
  /// Mínimo de 6 caracteres.
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  /// Origem: lib/alterar-dados.dart (_validateEmail)
  /// Campo OPCIONAL — retorna null se o valor for nulo/vazio. Mesma regex
  /// estrita do cadastro.
  ///
  /// INCONSISTÊNCIA: comportamento divergente de validateEmail (cadastro,
  /// obrigatório) e validateEmailLogin (login, obrigatório + regex diferente).
  static String? validateEmailEdit(String? value) {
    if (value != null && value.isNotEmpty) {
      const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailRegex).hasMatch(value)) {
        return 'Formato de e-mail inválido';
      }
    }
    return null;
  }

  /// Origem: lib/adicionar-musica.dart (_formatName) — duplicada em 6 arquivos.
  /// Capitaliza a primeira letra de cada palavra SEM aplicar toLowerCase
  /// no restante — ex.: "maRIA silva" → "MaRIA Silva".
  ///
  /// INCONSISTÊNCIA: diverge de capitalize (mapa.dart), que aplica
  /// toLowerCase ao restante da palavra.
static String formatName(String name) {
  return name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}

  /// Origem: lib/mapa.dart (_capitalize)
  /// Capitaliza a primeira letra E aplica toLowerCase no restante —
  /// ex.: "maRIA silva" → "Maria Silva". Trata palavras vazias internas.
  ///
  /// INCONSISTÊNCIA: diverge de formatName (adicionar-musica.dart), que
  /// preserva a caixa original do restante da palavra.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
