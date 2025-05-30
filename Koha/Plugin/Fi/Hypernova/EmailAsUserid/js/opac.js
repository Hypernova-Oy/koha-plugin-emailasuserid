//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/opac.js

let kpfheauid_bopr = document.querySelector('body#opac-patron-registration');
if (kpfheauid_bopr) {
  document.addEventListener("DOMContentLoaded", function () {
    $('body#opac-patron-registration input#borrower_cardnumber').parent('li').css('display', 'none');
    $('body#opac-patron-registration select#borrower_branchcode').parents('fieldset').css('display', 'none');

    $('body#opac-patron-registration input[name="borrower_userid"]').remove();
    $("<input />").attr("type", "hidden")
                  .attr("name", "borrower_userid")
                  .attr("id", "borrower_userid")
                  .attr("value", $('body#opac-patron-registration input#borrower_email').val())
                  .appendTo($('form[action="/cgi-bin/koha/opac-memberentry.pl"]'));

    kpfheauid_bopr.querySelector('form#memberentry-form').addEventListener('submit', function (e) {
      e.preventDefault();
      kpfheauid_bopr.querySelector('input#borrower_userid').value = kpfheauid_bopr.querySelector('input#borrower_email').value;
      return true;
    });
  });
}

let kpfheauid_bopu = document.querySelector('body#opac-patron-update');
if (kpfheauid_bopu) {
  document.addEventListener("DOMContentLoaded", function () {
    let useridElem = kpfheauid_bopu.querySelector('input[name="borrower_userid"]');
    if (useridElem) { useridElem.remove(); }
    $("<input />").attr("type", "hidden")
                  .attr("name", "borrower_userid")
                  .attr("id", "borrower_userid")
                  .attr("value", $('input#borrower_email').val())
                  .appendTo($('form[action="/cgi-bin/koha/opac-memberentry.pl"]'));

    kpfheauid_bopu.querySelector('input#borrower_email').addEventListener('change', function (e) {
      kpfheauid_bopu.querySelector('input#borrower_userid').value = kpfheauid_bopu.querySelector('input#borrower_email').value;
    });
  });
}

let kpfheauid_localLogins = document.querySelectorAll('div.local-login, div#login');
if (kpfheauid_localLogins) {
  document.addEventListener("DOMContentLoaded", function () {
    let useridTranslation = kpfheauid_getUseridFieldTranslation();
    kpfheauid_localLogins.forEach((oull) => {
      let userid = oull.querySelector('label[for=userid]');
      if (userid) { userid.innerHTML = useridTranslation; }
      let muserid = oull.querySelector('label[for=muserid]');
      if (muserid) { muserid.innerHTML = useridTranslation; }
    });
  });
}

let kpfheauid_passwordRecovery = document.querySelector('body#opac-password-recovery div#password-recovery');
if (kpfheauid_passwordRecovery) {
  if (! kpfheauid_config.card) {
    let cardInput = kpfheauid_passwordRecovery.querySelector('.form-group:nth-of-type(1)');
    if (cardInput) {
      cardInput.style.display = 'none';
    }

    let paragraph = kpfheauid_passwordRecovery.querySelector('form p:nth-of-type(1)');
    if (paragraph) {
      if (document.documentElement.lang === "en") {
        paragraph.innerHTML = "To reset your password, enter your email address.";
      } else if (document.documentElement.lang === "fi-FI") {
        paragraph.innerHTML = "Palauttaaksesi salasanasi, anna sähköpostiosoite.";
      } else if (document.documentElement.lang === "sv-SE") {
        paragraph.innerHTML = "För att återställa ditt lösenord, ange din e-postadress.";
      }
    }
  }
}