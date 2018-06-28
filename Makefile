test:
	@bundle exec rspec spec

mutant:
	@bundle exec mutant --include lib --require lsp --use rspec "Lsp::FileLanguageServer"
