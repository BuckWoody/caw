var processCoopDivs = function () {
    var config = {
        filePath1: "../info/EmergencySteps1.txt",
        filePath2: "../info/EmergencySteps2.txt",
        filePath3: "../info/EmergencySteps3.txt"
    };

    populateDivs = function () {
        readTextFile(config.filePath1, '#step1')
        readTextFile(config.filePath2, '#step2')
        readTextFile(config.filePath3, '#step3')
    };

    readTextFile = function (filePath, divPlaceholder) {
        $.get(filePath, function (textContents) {
            $(divPlaceholder).html(textContents)
        }, 'text');
    };

   return {
       populateDivs: populateDivs
    }
}();

$(document).ready(function () {
    StartPageScript();
});

function StartPageScript() {
    processCoopDivs.populateDivs();
}