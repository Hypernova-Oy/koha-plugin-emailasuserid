//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/opac.js

let kpfheauid_bopr = document.querySelector('body#opac-patron-registration');
if (kpfheauid_bopr) {
  document.addEventListener("DOMContentLoaded", function () {
    if (kpfheauid_config.studentcard) {
      document.querySelector("label[for='borrower_cardnumber']").innerHTML = kpfheauid_ucFirst(kpfheauid_getTranslation("card"));
    }

    if (kpfheauid_config.hide_branchcode_selection) {
      let branchcodeElemJq = $('body#opac-patron-registration select#borrower_branchcode');
      if (branchcodeElemJq.parents('fieldset').find("li").length > 1) {
        branchcodeElemJq.parents("li").css('display', 'none');
      }
      else {
        branchcodeElemJq.parents('fieldset').css('display', 'none');
      }
    }

    if (kpfheauid_config.force_email) {
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
    }
  });
}

let kpfheauid_bopu = document.querySelector('body#opac-patron-update');
if (kpfheauid_bopu) {
  document.addEventListener("DOMContentLoaded", function () {
    if (kpfheauid_config.studentcard) {
      document.querySelector("label[for='borrower_cardnumber']").innerHTML = kpfheauid_ucFirst(kpfheauid_getTranslation("card"));
    }

    if (kpfheauid_config.hide_branchcode_selection) {
      let branchcodeElemJq = $('body#opac-patron-update select#borrower_branchcode');
      if (branchcodeElemJq.parents('fieldset').find("li").length > 1) {
        branchcodeElemJq.parents("li").css('display', 'none');
      }
      else {
        branchcodeElemJq.parents('fieldset').css('display', 'none');
      }
    }

    if (kpfheauid_config.force_email) {
      let useridElem = kpfheauid_bopu.querySelector('input[name="borrower_userid"]');
      if (useridElem) { useridElem.remove(); }
      $("<input />").attr("type", "hidden")
                    .attr("name", "borrower_userid")
                    .attr("id", "borrower_userid")
                    .attr("value", $('input#borrower_email').val())
                    .appendTo($('form[action="/cgi-bin/koha/opac-memberentry.pl"]'));

      kpfheauid_bopu.querySelector('input#borrower_email').addEventListener('change', function (e) {
        kpfheauid_bopu.querySelector('input#borrower_userid').value = e.target.value;
      });
    }
  });
}

let kpfheauid_localLogins = document.querySelectorAll('div.local-login, div#login');
if (kpfheauid_localLogins) {
  document.addEventListener("DOMContentLoaded", function () {
    let useridTranslation = kpfheauid_ucFirst(kpfheauid_getUseridFieldTranslationInLoginForm());
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
      paragraph.innerHTML = kpfheauid_getTranslation("pass_reset_email");
    }
  }
  else if (kpfheauid_config.card && kpfheauid_config.studentcard && kpfheauid_config.email) {
    let paragraph = kpfheauid_passwordRecovery.querySelector('form p:nth-of-type(1)');
    if (paragraph) {
      paragraph.innerHTML = kpfheauid_getTranslation("pass_reset_email_studentcard");
    }
  }
  if (kpfheauid_config.studentcard) {
    document.querySelector("label[for='username']").innerHTML = kpfheauid_ucFirst(kpfheauid_getTranslation("card"));
  }
  else {
    // default Koha behaviour
  }
}