module.exports = {
  // O preset que diz ao Jest como lidar com arquivos TypeScript
  preset: 'ts-jest',
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageProvider: 'v8',

  // O padrão de glob para encontrar nossos arquivos de teste
  testMatch: [
    '<rootDir>/tests/unit/**/*.test.ts'
  ],

  // Limpa mocks entre os testes
  clearMocks: true,
  // Ignora o diretório de build para evitar a 'naming collision'
  modulePathIgnorePatterns: ['<rootDir>/.build'],
};