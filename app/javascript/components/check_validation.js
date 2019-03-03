// Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
// License: GNU AGPL-3+ (see full text in LICENSE file)

function checkValidationInitialize() {
  const element = document.getElementById("check_domain");

  if (element && element.dataset.kind == "domain") {
    addEventSupportListener(element);
  }
}

function addEventSupportListener(element) {
  element.addEventListener("blur", event => {
    const request = $.ajax("/checks/supports.json", {
      method: "post",
      dataType: "json",
      data: {
        check: {
          domain: event.target.value,
          kind: element.dataset.kind,
        }
      }
    })

    request.done(response => {
      const { supported } = response.check;

      toggleUnsupportedContainers(supported);
      setFocus(supported);

      // set normalized domain
      element.value = response.check.domain;
    });
  });
}

function toggleUnsupportedContainers(supported) {
  const containerClass = supported ? "d-none" : "d-block";

  document.getElementById("check_domain_expires_at_container").className = containerClass;

  const domainHint = document.getElementById("check_domain_unsupported_container");
  domainHint.classList.remove("d-none");
  domainHint.classList.remove("d-block");
  domainHint.classList.add(containerClass);
}


function setFocus(supported) {
  if (supported) {
    return;
  }

  document.getElementById("check_domain_expires_at").focus();
}

export default checkValidationInitialize;
