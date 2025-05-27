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

let kpfheauid_localLogins = document.querySelectorAll('div.local-login');
if (kpfheauid_localLogins) {
  document.addEventListener("DOMContentLoaded", function () {
    let useridTranslation = "Email or card number";
    if (document.documentElement.lang === "fi-FI") { useridTranslation = "Sähköposti tai kirjastokortin numero"; }
    else if (document.documentElement.lang === "sv-SE") { useridTranslation = "E-post eller lånekortsnummer"; }
    kpfheauid_localLogins.forEach((oull) => {
      let userid = oull.querySelector('label[for=userid]');
      if (userid) { userid.innerHTML = useridTranslation; }
      let muserid = oull.querySelector('label[for=muserid]');
      if (muserid) { muserid.innerHTML = useridTranslation; }
    });
  });
}