export function getDomain(email?: string): string {
  const domain = ['ctison', 'dev'].join('.');
  return email ? [email, domain].join('@') : domain;
}
