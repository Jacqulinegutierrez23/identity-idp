import { Crypto } from '@peculiar/webcrypto';
import chai from 'chai';
import dirtyChai from 'dirty-chai';
import sinonChai from 'sinon-chai';
import chaiAsPromised from 'chai-as-promised';
import { I18n } from '@18f/identity-i18n';
import { createDOM, useCleanDOM } from './support/dom';
import { chaiConsoleSpy, useConsoleLogSpy } from './support/console';
import { sinonChaiAsPromised } from './support/sinon';
import { createObjectURLAsDataURL } from './support/file';

chai.use(sinonChai);
chai.use(chaiAsPromised);
chai.use(chaiConsoleSpy);
chai.use(sinonChaiAsPromised);
chai.use(dirtyChai);
global.expect = chai.expect;

// Emulate a DOM, since many modules will assume the presence of these globals exist as a side
// effect of their import.
const dom = createDOM();
global.window = dom.window;
const windowGlobals = Object.fromEntries(
  Object.getOwnPropertyNames(window)
    .filter((key) => !(key in global))
    .map((key) => [key, window[key]]),
);
Object.assign(global, windowGlobals);
global.window.fetch = () => Promise.reject(new Error('Fetch must be stubbed'));
global.window.crypto = new Crypto(); // In the future (Node >=15), use native webcrypto: https://nodejs.org/api/webcrypto.html
global.window.URL.createObjectURL = createObjectURLAsDataURL;
global.window.URL.revokeObjectURL = () => {};
global.window.LoginGov = global.window.LoginGov || {};
global.window.LoginGov.I18n = new I18n();
Object.defineProperty(global.window.Image.prototype, 'src', {
  set() {
    this.onload();
  },
});

useCleanDOM(dom);
useConsoleLogSpy();
