"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const PickLIst_1 = require("./PickLIst");
const vsHelp = {
    /**
     * 展示信息提示框
     *
     * @param {string} content 提示内容
     * @returns {Thenable<string>}
     */
    showInfo(content) {
        return vscode.window.showInformationMessage(content);
    },
    /**
     * 提示信息并重启
     *
     * @param {any} content 提示内容
     * @returns {Thenable<void>}
     */
    showInfoRestart(content) {
        return vscode.window.showInformationMessage(content, { title: "Reload" })
            .then(function (item) {
            if (!item) {
                return;
            }
            vscode.commands.executeCommand('workbench.action.reloadWindow');
        });
    },
    showInfoWxChat(content) {
        return vscode.window.showInformationMessage(content, { title: "OK" })
            .then(function (item) {
            if (!item) {
                return;
            }
            PickLIst_1.PickList.gotoFilePath('//resources//wx.jpg');
        });
    }
};
exports.default = vsHelp;
//# sourceMappingURL=vsHelp.js.map