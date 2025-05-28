//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js

function kpfheauid_getUseridFieldTranslation() {
  if (kpfheauid_config.card) {
    if (document.documentElement.lang === "en") {
      return "Email or card number";
    } else if (document.documentElement.lang === "fi-FI") {
      return "Sähköposti tai kirjastokortin numero";
    } else if (document.documentElement.lang === "sv-SE") {
      return "E-post eller lånekortsnummer";
    }
  }
  else {
    if (document.documentElement.lang === "en") {
      return "Email";
    } else if (document.documentElement.lang === "fi-FI") {
      return "Sähköposti";
    } else if (document.documentElement.lang === "sv-SE") {
      return "E-post";
    }
  }

  return 'Koha::Plugin::Fi::Hypernova::EmailAsUserid:> Unknown HTML document language "'+document.documentElement.lang+'"';
}
