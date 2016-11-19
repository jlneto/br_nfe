require 'test_helper'

describe BrNfe::Product::Nfe::Item do
	subject { FactoryGirl.build(:product_item) }
	
	describe 'Default values' do
		it "for tipo_produto" do
			subject.class.new.tipo_produto.must_equal :product
		end
		it "for soma_total_nfe" do
			subject.class.new.soma_total_nfe.must_equal true
		end
	end

	describe 'Validations' do
		before do 
			MiniTest::Spec.string_for_validation_length = '1'
		end
		after do 
			MiniTest::Spec.string_for_validation_length = 'x'
		end
		it { must validate_numericality_of(:total_frete).allow_nil }
		it { must validate_numericality_of(:total_seguro).allow_nil }
		it { must validate_numericality_of(:total_desconto).allow_nil }
		it { must validate_numericality_of(:total_outros).allow_nil }
		it { must validate_length_of(:codigo_cest).is_at_most(7) }
		
		it { must validate_length_of(:numero_pedido_compra).is_at_most(15) }
		it { must allow_value('').for(:numero_pedido_compra) }

		it { must validate_length_of(:item_pedido_compra).is_at_most(6) }
		it { must allow_value('').for(:item_pedido_compra) }
		
		describe "numero_fci" do
			it { must validate_length_of(:numero_fci).is_equal_to(36) }
			it { must allow_value('').for(:numero_fci) }
			it { must allow_value('B01F70AF-10BF-4B1F-848C-65FF57F616FE').for(:numero_fci) }
			it { must allow_value('11111111-1111-1111-1111-999999999999').for(:numero_fci) }
			it { must allow_value('ABCDEFAA-AAAA-AAAA-AAAA-FFFFFFFFFFFF').for(:numero_fci) }
			it { must allow_value('ABCDEFAA1AAAA2AAAA0AAAA9FFFFFFFFFFFF').for(:numero_fci) }
			# NÃO DEVE ACEITAR LETRAS A CIMA DE F
			it { wont allow_value('ABCDEFGGGGAAA2AAAA0AAAA9FFFFFFFFFFFF').for(:numero_fci) }
			it { wont allow_value('ABCDEFZZZZAAA2AAAA0AAAA9FFFFFFFFFFFF').for(:numero_fci) }
			# NÃO DEVE ACEITAR LETRAS minúsculas
			it { wont allow_value('abcdefaaaaaaa2aaaa0aaaa9ffffffffffff').for(:numero_fci) }
			# NÃO DEVE ACEITAR caracteres especiais a não ser hífen
			it { wont allow_value('ABCDEFAA@AAAA#AAAA$AAAA_FFFFFF,FFFFF').for(:numero_fci) }
			
		end

		describe "tipo_produto" do
			it { must validate_presence_of(:tipo_produto) }
			it { must validate_inclusion_of(:tipo_produto).in_array([:product, :service, :other]) }
		end
		describe "codigo_produto" do
			it { must validate_length_of(:codigo_produto).is_at_most(60) }
		end
		describe "codigo_ean" do
			it { must validate_length_of(:codigo_ean).is_at_most(14) }
		end
		describe "descricao_produto" do
			it { must validate_length_of(:descricao_produto).is_at_most(120) }
		end
		describe "codigo_ncm" do
			context "quando o tipo_produto for :product" do
				before { subject.stubs(:is_product?).returns(true) }
				it { must validate_length_of(:codigo_ncm).is_at_most(8) }
				it { wont validate_length_of(:codigo_ncm).is_at_most(2) }
			end
			context "quando o tipo_produto não for :product" do
				before { subject.stubs(:is_product?).returns(false) }
				it { must validate_length_of(:codigo_ncm).is_at_most(2) }
				it { wont validate_length_of(:codigo_ncm).is_at_most(8) }
			end
		end
		describe "codigos_nve" do
			it "Deve ter no máximo 8 códigos" do
				MiniTest::Spec.string_for_validation_length = ['AA1324']
				must validate_length_of(:codigos_nve).is_at_most(8)
				MiniTest::Spec.string_for_validation_length = 'x'
			end
		end

		describe 'codigo_extipi' do
			it { must validate_length_of(:codigo_extipi).is_at_least(2).is_at_most(3) }
			it "se não preencher o atributo não deve valida-lo" do
				subject.codigo_extipi = ''
				wont_be_message_error :codigo_extipi
			end
		end

		describe 'unidade_comercial' do
			it { must validate_presence_of(:unidade_comercial) }
			it { must validate_length_of(:unidade_comercial).is_at_most(6) }
		end
		describe 'quantidade_comercial' do
			it { must validate_presence_of(:quantidade_comercial) }
			it { must validate_numericality_of(:quantidade_comercial) }
		end
		describe 'valor_unitario_comercial' do
			before { subject.quantidade_comercial = 0 }
			it { must validate_presence_of(:valor_unitario_comercial) }
			it { must validate_numericality_of(:valor_unitario_comercial) }
		end
		describe 'valor_total_produto' do
			it { must validate_presence_of(:valor_total_produto) }
			it { must validate_numericality_of(:valor_total_produto) }
		end
		describe "codigo_ean_tributavel" do
			it { must validate_length_of(:codigo_ean_tributavel).is_at_most(14) }
		end
		describe 'quantidade_tributavel' do
			before { subject.quantidade_comercial = nil }
			it { must validate_presence_of(:quantidade_tributavel) }
			it { must validate_numericality_of(:quantidade_tributavel) }
		end
		describe 'unidade_tributavel' do
			before { subject.unidade_comercial = nil }
			it { must validate_presence_of(:unidade_tributavel) }
			it { must validate_length_of(:unidade_tributavel).is_at_most(6) }
		end
		describe 'valor_unitario_tributavel' do
			before { subject.quantidade_tributavel = 0 }
			it { must validate_presence_of(:valor_unitario_tributavel) }
			it { must validate_numericality_of(:valor_unitario_tributavel) }
		end
	end

	describe "cfop" do
		it "Só aceita números" do
			must_accept_only_numbers :cfop
		end
	end

	describe 'codigo_ean' do
		it "Só aceita números" do
			must_accept_only_numbers :codigo_ean
		end
		it "deve ter alias para codigo_gtin" do
			must_have_alias_attribute :codigo_gtin, :codigo_ean, '1234'
		end
	end

	describe '#codigo_produto' do
		it "deve retornar o valor da CFOP se não preenchero valor e tiver cfop" do
			subject.cfop = 7896
			subject.codigo_produto = ''
			subject.codigo_produto.must_equal 'CFOP7896'
		end
		it "deve retornar vazio se não preenchero valor e cfop estiver sem preencher" do
			subject.cfop = ''
			subject.codigo_produto = ''
			subject.codigo_produto.must_equal ''
		end
		it "deve retornar o valor setado mesmo que tiver cfop preenchido" do
			subject.cfop = '7896'
			subject.codigo_produto = 'PROD7844'
			subject.codigo_produto.must_equal 'PROD7844'
		end
	end

	describe '#codigo_ncm' do
		it "Só aceita números" do
			must_accept_only_numbers :codigo_ncm
		end
		it "se for um produto e não tiver valor não deve setar o valor 00" do
			subject.tipo_produto = :product
			subject.codigo_ncm = ''
			subject.codigo_ncm.must_equal ''
		end
		it "se não for um produto e não tiver valor deve setar o valor 00" do
			subject.tipo_produto = :service
			subject.codigo_ncm = ''
			subject.codigo_ncm.must_equal '00'
			subject.tipo_produto = :other
			subject.codigo_ncm = ''
			subject.codigo_ncm.must_equal '00'
		end
	end

	describe '#codigos_nve' do
		it { must_returns_an_array :codigos_nve }
	end

	describe 'codigo_ean_tributavel' do
		it "Só aceita números" do
			must_accept_only_numbers :codigo_ean_tributavel
		end
		it "deve ter alias para codigo_gtin" do
			must_have_alias_attribute :codigo_gtin_tributavel, :codigo_ean_tributavel, '1234'
		end
	end

	describe '#quantidade_tributavel' do
		it "se a quantidade_tributavel for nil, deve considerar o valor de quantidade_comercial" do
			subject.quantidade_tributavel = nil
			subject.quantidade_comercial = 8
			subject.quantidade_tributavel.must_equal 8
		end
		it "se tiver quantidade_tributavel não deve considerar o valor de quantidade_comercial" do
			subject.quantidade_tributavel = 12
			subject.quantidade_comercial = 8
			subject.quantidade_tributavel.must_equal 12
		end
	end

	describe '#unidade_tributavel' do
		it "se a unidade_tributavel for nil, deve considerar o valor de unidade_comercial" do
			subject.unidade_tributavel = nil
			subject.unidade_comercial = 'PC'
			subject.unidade_tributavel.must_equal 'PC'
		end
		it "se tiver unidade_tributavel não deve considerar o valor de unidade_comercial" do
			subject.unidade_tributavel = 'KG'
			subject.unidade_comercial = 'PC'
			subject.unidade_tributavel.must_equal 'KG'
		end
	end

	describe '#valor_unitario_comercial' do
		before do
			subject.valor_unitario_comercial = nil
			subject.valor_total_produto = 500.00
			subject.quantidade_comercial = 3.55
		end
		it "se não tiver valor setado deve calcular = valor_total_produto/quantidade_comercial" do
			subject.valor_unitario_comercial.must_equal 140.8450704225
		end
		it "caso seja setado um valor no atributo não deve calcular" do
			subject.valor_unitario_comercial = 140.0
			subject.valor_unitario_comercial.must_equal 140.0
		end
		it "não deve calcular se a quantidade_comercial for nil ou zero" do
			subject.quantidade_comercial = nil
			subject.valor_unitario_comercial.must_be_nil
			subject.quantidade_comercial = 0
			subject.valor_unitario_comercial.must_be_nil
			subject.quantidade_comercial = 1
			subject.valor_unitario_comercial.wont_be_nil
		end
	end
	describe '#valor_unitario_tributavel' do
		before do
			subject.valor_unitario_comercial = nil
			subject.quantidade_comercial     = nil

			subject.valor_unitario_tributavel = nil
			subject.valor_total_produto = 600.00
			subject.quantidade_tributavel = 3.55
		end
		it "se não tiver valor setado deve calcular = valor_total_produto/quantidade_tributavel" do
			subject.valor_unitario_tributavel.must_equal 169.014084507
		end
		it "caso seja setado um valor no atributo não deve calcular" do
			subject.valor_unitario_tributavel = 140.0
			subject.valor_unitario_tributavel.must_equal 140.0
		end
		it "não deve calcular se a quantidade_tributavel for nil ou zero" do
			subject.quantidade_tributavel = nil
			subject.valor_unitario_tributavel.must_be_nil
			subject.quantidade_tributavel = 0
			subject.valor_unitario_tributavel.must_be_nil
			subject.quantidade_tributavel = 1
			subject.valor_unitario_tributavel.wont_be_nil
		end
	end

	describe '#declaracoes_importacao' do
		it { must_validate_length_has_many(:declaracoes_importacao, BrNfe.declaracao_importacao_product_class, {maximum: 100})  }
		it { must_validates_has_many(:declaracoes_importacao, BrNfe.declaracao_importacao_product_class, :invalid_declaracao_importacao) }
		it { must_have_many(:declaracoes_importacao, BrNfe.declaracao_importacao_product_class, {numero_documento: 'XXL9999', local_desembaraco: '223'})  }
	end
	describe '#detalhes_exportacao' do
		it { must_have_many(:detalhes_exportacao, BrNfe.detalhe_exportacao_product_class, {numero_drawback: '46464', numero_registro: '223'})  }
		it { must_validates_has_many(:detalhes_exportacao, BrNfe.detalhe_exportacao_product_class, :invalid_detalhe_exportacao) }
	end
end