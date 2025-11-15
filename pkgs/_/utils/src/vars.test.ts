import { expect, test } from 'bun:test';
import * as vars from './vars';

test('Email', () => {
  expect(vars.getDomain()).toMatch(/^\w+\.\w+$/);
  expect(vars.getDomain('user')).toMatch(/^user@\w+\.\w+$/);
});
