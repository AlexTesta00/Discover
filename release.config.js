module.exports = {
  branches: ['main'],
  plugins: [
    ['@semantic-release/commit-analyzer', {
      preset: 'conventionalcommits'
    }],
    ['@semantic-release/release-notes-generator', {
      preset: 'conventionalcommits'
    }],
    ['@semantic-release/changelog', { changelogFile: 'CHANGELOG.md' }],
    ['@semantic-release/github', {
      assets: [
        {
          path: 'build/app/outputs/flutter-apk/app-debug.apk',
          label: 'Android Debug APK'
        }
      ]
    }],
    ['@semantic-release/git', {
      assets: ['CHANGELOG.md', 'package.json'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }]
  ]
}
