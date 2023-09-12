#!/usr/bin/env bun

for (let i = 0; true; ++i) {
  const notifications = await fetchGithubApi<Notification[]>(
    `/notifications?page=${i}`,
  );
  if (notifications.length === 0) break;
  await Promise.all(
    notifications.map(async (notification) => {
      if (notification.subject.type !== 'Release') return undefined;
      const title = notification.subject.title;
      if (title.match(/\d+\.\d+\.0/) || !title.match(/\d+\.\d+\.\d+/)) {
        const path = notification.subject.url.replace(
          'https://api.github.com',
          '',
        );
        const release = await fetchGithubApi<Release>(path);
        if (release.prerelease) return undefined;
        console.log(`${release.html_url}`);
      }
    }),
  );
}

async function fetchGithubApi<T = unknown>(path: string): Promise<T> {
  const proc = Bun.spawn(['gh', 'api', path]);
  const exitCode = await proc.exited;
  if (exitCode !== 0) {
    const response = await new Response(proc.stderr).text();
    throw new Error(`gh api exited with code ${exitCode}: ${response}`);
  }
  const response = await new Response(proc.stdout).json();
  return response as T;
}

type Notification = {
  subject: {
    title: string;
    type: 'Release' | string;
    url: string;
  };
};

type Release = {
  html_url: string;
  prerelease: boolean;
};
