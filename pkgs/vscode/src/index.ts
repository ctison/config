import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(
    vscode.commands.registerCommand('ctison.run-script', () => {
      vscode.window.showInformationMessage('Hello World!');
    }),
  );
}
