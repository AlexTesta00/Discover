module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    [
      '@semantic-release/github',
      {
        assets: [
          {
            path: 'build/app/outputs/flutter-apk/app-debug.apk',
            label: 'Android Debug APK'
          }
        ]
      }
    ]
  ]
}
