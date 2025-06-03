//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/mainpage.js

if (kpfheauid_config.pending_self_registrations_categorycode) {
  $(document).ready(function() {
    if ($("body#main_intranet-main").length) {
      $.ajax({
        url: '/api/v1/patrons?_page=1&_per_page=20&q={"-and":[[{"me.category_id":"'+kpfheauid_config.pending_self_registrations_categorycode+'"}]]}&_match=contains&_order_by=+me.surname,+me.preferred_name,+me.firstname,+me.middle_name,+me.othernames,+me.street_number,+me.address,+me.address2,+me.city,+me.state,+me.postal_code,+me.country'
      }).done(function(data) {
        if (data.length === 0) { return; }
        let kpfheauid_sr_translation;
        if (document.documentElement.lang === "en") {
          kpfheauid_sr_translation = "Pending self-registrations";
        } else if (document.documentElement.lang === "fi-FI") {
          kpfheauid_sr_translation = "Keskeneräiset itserekisteröinnit";
        } else if (document.documentElement.lang === "sv-SE") {
          kpfheauid_sr_translation = "Väntande självregistreringar";
        }
        $($("ul.biglinks-list li:last-of-type")[0]).after(`<li>
  <a class="icon_general icon_circulation" href="/cgi-bin/koha/reports/guided_reports.pl?id=${kpfheauid_config.pending_self_registrations_report_id}&op=run"><i class="fa fa-fw fa-id-card"></i>${kpfheauid_sr_translation} <span class="pending-number-link"> (${data.length})</span></a>
</li>`);
      });
    }
  });
}