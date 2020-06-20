module Geographic

	def self.get_neighborhood_from_address(address)
		neighborhoods = ["Aberta dos Morros", "Agronomia", "Anchieta", "Arquipélago", "Auxiliadora", "Azenha", "Bela Vista", "Belém Novo", "Belém Velho", "Boa Vista", "Bom Jesus", "Bom Fim", "Camaquã", "Campo Novo", "Cascata", "Cavalhada", "Centro", "Chácara das Pedras", "Chapéu do Sol", "Cidade Baixa", "Coronel Aparício Borges", "Cristal", "Cristo Redentor", "Espírito Santo", "Farrapos", "Farroupilha", "Floresta", "Glória", "Guarujá", "Higienópolis", "Hípica", "Humaitá", "Independência", "Ipanema", "Jardim Botânico", "Jardim Carvalho", "Jardim Dona Leopoldina", "Jardim Floresta", "Jardim Isabel", "Jardim Itu-Sabará", "Jardim Lindóia", "Jardim do Salso", "Jardim São Pedro", "Lageado", "Lami", "Lomba do Pinheiro", "Marcílio Dias", "Mário Quintana", "Medianeira", "Menino Deus", "Moinhos de Vento", "Mont'Serrat", "Navegantes", "Nonoai", "Partenon", "Passo D'Areia", "Passo das Pedras", "Pedra Redonda", "Petrópolis", "Ponta Grossa", "Praia de Belas", "Restinga", "Rio Branco", "Rubem Berta", "Santa Cecília", "Santa Maria Goretti", "Santa Tereza", "Santana", "Santo Antônio", "São Geraldo", "São João", "São José", "São Sebastião", "Sarandi", "Serraria", "Teresópolis", "Três Figueiras", "Tristeza", "Vila Assunção", "Vila Conceição", "Vila Ipiranga", "Vila Jardim", "Vila João Pessoa", "Vila Nova", "Zona Indefinida"]

		neighborhoods.each do |neighborhood|
			return neighborhood if address.include? neighborhood
		end
	end


	def self.get_cep_from_address(address)
		return address[/[0-9]{5}-[\d]{3}/] unless address[/[0-9]{5}-[\d]{3}/].nil?
		return "#{address[/[0-9]{8}/][0...5]}-#{address[/[0-9]{8}/][5...8]}" unless address[/[0-9]{8}/].nil?
		return "#{address[/[0-9]{5}/]}-000" unless address[/[0-9]{5}/].nil?
	end


	def self.get_valid_neighborhoods
		return ["Aberta dos Morros", "Agronomia", "Anchieta", "Arquipélago", "Auxiliadora", "Azenha", "Bela Vista", "Belém Novo", "Belém Velho", "Boa Vista", "Bom Jesus", "Bom Fim", "Camaquã", "Campo Novo", "Cascata", "Cavalhada", "Centro", "Chácara das Pedras", "Chapéu do Sol", "Cidade Baixa", "Coronel Aparício Borges", "Cristal", "Cristo Redentor", "Espírito Santo", "Farrapos", "Farroupilha", "Floresta", "Glória", "Guarujá", "Higienópolis", "Hípica", "Humaitá", "Independência", "Ipanema", "Jardim Botânico", "Jardim Carvalho", "Jardim Dona Leopoldina", "Jardim Floresta", "Jardim Isabel", "Jardim Itu-Sabará", "Jardim Lindóia", "Jardim do Salso", "Jardim São Pedro", "Lageado", "Lami", "Lomba do Pinheiro", "Marcílio Dias", "Mário Quintana", "Medianeira", "Menino Deus", "Moinhos de Vento", "Mont'Serrat", "Navegantes", "Nonoai", "Partenon", "Passo D'Areia", "Passo das Pedras", "Pedra Redonda", "Petrópolis", "Ponta Grossa", "Praia de Belas", "Restinga", "Rio Branco", "Rubem Berta", "Santa Cecília", "Santa Maria Goretti", "Santa Tereza", "Santana", "Santo Antônio", "São Geraldo", "São João", "São José", "São Sebastião", "Sarandi", "Serraria", "Teresópolis", "Três Figueiras", "Tristeza", "Vila Assunção", "Vila Conceição", "Vila Ipiranga", "Vila Jardim", "Vila João Pessoa", "Vila Nova", "Zona Indefinida"]
	end

end

