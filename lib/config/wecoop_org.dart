/// Anagrafica istituzionale WECOOP APS — unica fonte per sede, CF, RUNTS, contatti.
/// Allineata a Documento Unico V1.0 e Informativa Privacy GDPR V1.0 (Settembre 2026).
class WecoopOrg {
  WecoopOrg._();

  static const String name = 'WECOOP APS';
  static const String codiceFiscale = '97977210158';
  static const String runts = 'n. 142852';
  static const String sedeLegale =
      "Via Benefattori dell'Ospedale 3, 20159 Milano (MI)";
  static const String sedeOperativa = 'Via Populonia 8, Milano';
  static const String officeAddressMaps = 'Via Populonia 8, 20159 Milano MI';
  static const String phoneDisplay = '+39 351 511 2113';
  static const String phoneTel = '+393515112113';
  static const String email = 'info@wecoop.org';
  static const String web = 'wecoop.org';
  static const String webUrl = 'https://wecoop.org';

  /// Blocco "Versione app e fatturazione" (IT).
  static const String companyDetailsIt =
      '$name\n'
      'Sede legale: $sedeLegale\n'
      'Sede operativa / Sportello: $sedeOperativa\n'
      'Codice fiscale: $codiceFiscale\n'
      'RUNTS: $runts\n'
      'Tel.: $phoneDisplay\n'
      'E-mail: $email\n'
      'Web: $web';

  static const String companyDetailsEn =
      '$name\n'
      'Registered office: $sedeLegale\n'
      'Operational office / Desk: $sedeOperativa\n'
      'Tax code: $codiceFiscale\n'
      'RUNTS: $runts\n'
      'Tel.: $phoneDisplay\n'
      'E-mail: $email\n'
      'Web: $web';

  static const String companyDetailsFr =
      '$name\n'
      'Siège légal: $sedeLegale\n'
      'Siège opérationnel / Guichet: $sedeOperativa\n'
      'Code fiscal: $codiceFiscale\n'
      'RUNTS: $runts\n'
      'Tél.: $phoneDisplay\n'
      'E-mail: $email\n'
      'Web: $web';

  static const String companyDetailsEs =
      '$name\n'
      'Sede legal: $sedeLegale\n'
      'Sede operativa / Ventanilla: $sedeOperativa\n'
      'Código fiscal: $codiceFiscale\n'
      'RUNTS: $runts\n'
      'Tel.: $phoneDisplay\n'
      'E-mail: $email\n'
      'Web: $web';

  static const String companyDetailsAr =
      '$name\n'
      'المقر القانوني: $sedeLegale\n'
      'المقر التشغيلي / الشباك: $sedeOperativa\n'
      'الرمز الضريبي: $codiceFiscale\n'
      'RUNTS: $runts\n'
      'الهاتف: $phoneDisplay\n'
      'البريد: $email\n'
      'الويب: $web';

  static const String companyDetailsZh =
      '$name\n'
      '注册地址: $sedeLegale\n'
      '运营地址 / 柜台: $sedeOperativa\n'
      '税号: $codiceFiscale\n'
      'RUNTS: $runts\n'
      '电话: $phoneDisplay\n'
      '邮箱: $email\n'
      '网站: $web';

  static const String paymentFooterCf =
      '$name · Codice fiscale $codiceFiscale';
}
