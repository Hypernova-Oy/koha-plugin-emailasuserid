//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js

function kpfheauid_getUseridFieldTranslationInLoginForm() {
  if (! kpfheauid_getTranslation("or")) {
    return 'Koha::Plugin::Fi::Hypernova::EmailAsUserid:> Unknown HTML document language "'+document.documentElement.lang+'"';
  }
  if (kpfheauid_config.card && kpfheauid_config.email) {
    return kpfheauid_getTranslation("email")+" "+kpfheauid_getTranslation("or")+" "+kpfheauid_getTranslation("card");
  }
  if (kpfheauid_config.email) {
    return kpfheauid_getTranslation("email");
  }
  if (kpfheauid_config.card) {
    return kpfheauid_getTranslation("card");
  }
}

let kpfheauid_translations = {
  "en": {
    "card": kpfheauid_config.studentcard ? "student card number" : "library card number",
    "email": "email",
    "or": "or",
    "pass_reset_email": "To reset your password, enter your email address.",
    "pass_reset_email_studentcard": "To reset your password, enter your student card number or email address.",
  },
  "fi-FI": {
    "card": kpfheauid_config.studentcard ? "opiskelijakortin numero" : "kirjastokortin numero",
    "email": "sähköposti",
    "or": "tai",
    "pass_reset_email": "Palauttaaksesi salasanasi, anna sähköpostiosoite.",
    "pass_reset_email_studentcard": "Palauttaaksesi salasanasi, anna opiskelijakorttisi numero tai sähköpostiosoite.",
  },
  "sv-SE": {
    "card": kpfheauid_config.studentcard ? "studentkortsnummer" : "lånekortsnummer",
    "email": "e-post",
    "or": "eller",
    "pass_reset_email": "För att återställa ditt lösenord, ange din e-postadress.",
    "pass_reset_email_studentcard": "För att återställa ditt lösenord, ange din studentkortsnummer eller e-postadress.",
  },
};
function kpfheauid_getTranslation(key) {
  return kpfheauid_translations[document.documentElement.lang][key];
}

function kpfheauid_ucFirst(str) { return str.charAt(0).toUpperCase() + str.slice(1) }
