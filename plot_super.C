{
 
	TFile *f1 = new TFile("plots.root");
TFile *f = new TFile("MC.hera+CMS.g.01.root","recreate");
	
	TGraph *g = (TGraph*)f1->Get("Center");
	TGraph *g_p = (TGraph*)f1->Get("Plus");
	TGraph *g_p_model = (TGraph*)f1->Get("Plus_model");
	TGraph *g_p_para = (TGraph*)f1->Get("Plus_para");
	TGraph *g_m_model = (TGraph*)f1->Get("Minus_model");
	TGraph *g_m_para = (TGraph*)f1->Get("Minus_para");
	TGraph *g_m = (TGraph*)f1->Get("Minus");
	TGraph *g_shade = (TGraph*)f1->Get("Shade");
	TGraph *g_shade_model = (TGraph*)f1->Get("Shade_model");
	TGraph *g_shade_para = (TGraph*)f1->Get("Shade_para");
	TGraph *g_MC = (TGraph*)f1->Get("Center_MC");
	TGraph *g_p_MC = (TGraph*)f1->Get("Plus_MC");
	TGraph *g_m_MC = (TGraph*)f1->Get("Minus_MC");
	TGraph *g_shade_MC = (TGraph*)f1->Get("Shade_MC");
	TGraph *g_p_MC_rel = (TGraph*)f1->Get("Plus_MC_rel");
	TGraph *g_m_MC_rel = (TGraph*)f1->Get("Minus_MC_rel");
	TGraph *g_shade_MC_rel = (TGraph*)f1->Get("Shade_MC_rel");
	TCanvas *c2 = new TCanvas("c2","",600,600);
	TCanvas *c1 = new TCanvas("c1","",600,600);
		
	g->GetYaxis()->SetTitleOffset(1.25);
	g_shade->SetFillColor(kRed);
	g_shade_model->SetFillColor(kYellow);
	g_shade_para->SetFillColor(kGreen);
	g_shade_MC->SetFillColor(kCyan);
	g_shade_MC_rel->SetFillColor(kCyan);
       	g->GetXaxis()->SetLabelFont(42); //font in pixels
   	g->GetYaxis()->SetLabelFont(42); //font in pixels
	g_p_MC_rel->GetXaxis()->SetLabelFont(42); //font in pixels
	g_p_MC_rel->GetXaxis()->SetTitle("x"); //font in pixels
   	g_p_MC_rel->GetYaxis()->SetLabelFont(42); //font in pixels
	g_p_MC_rel->GetYaxis()->SetLabelOffset(999);
	c1->cd();
	c1->Update();
	c1->SetLogx();
g->SetMaximum(4.5);
g_MC->SetMaximum(4.5);
	g->GetHistogram()->SetMinimum(-0.03);	
        g->Draw("AC");
        g_p_para->Draw("C");
        g_m_para->Draw("C");
        g_shade_para->Draw("f");
        g_p_model->Draw("SAME");
        g_m_model->Draw("SAME");
        g_shade_model->Draw("f");
        g_p->Draw("SAME");
        g_m->Draw("SAME");
        g_shade->Draw("f");
        g->Draw("SAME");
TLatex *tx = new TLatex(0.0001129711,4.535391,"CMS NLO");
   	tx->SetLineWidth(2);
   	tx->Draw();
TLatex *tx2 = new TLatex(0.04921771,4.105647,"Q^{2}=1.9 GeV^{2}");
	tx2->SetLineWidth(2);
	tx2->Draw();

	c2->cd();
	c2->Update();
	TPad *pad1 = new TPad("pad1","pad1",0,0,1,1);
	pad1->ResetAttPad();
	pad1->SetPad(0,0.25,1,1);
	//pad1->SetTopMargin(0.1);
	pad1->SetBottomMargin(0.16);
	pad1->Draw();
	pad1->cd();
	pad1->SetLogx();
		
	g_MC->Draw("AC");
	g_p_MC->Draw("C");
	g_m_MC->Draw("C");
       	g_shade_MC->Draw("f");
	g_MC->Draw("SAME");
	TLatex *   tex = new TLatex(0.0001219693,4.634165,"CMS NLO");
   	tex->SetLineWidth(2);
   	tex->Draw();
	TLatex *tex2 = new TLatex(0.126933,4.61909,"MC Method");
	tex2->SetLineWidth(2);
	tex2->Draw();
	//TLatex *tex3 = new TLatex(0.0001294095,0.5482045,"HERAI+II DIS");
   	//tex3->SetLineWidth(2);
	//tex3->Draw();

	pad1->Modified();


	pad1->Update();

	TPad *pad2 = new TPad("pad2","pad2",0,0,1,1);
	pad2->ResetAttPad();
	pad2->SetPad(0,-0.3.0,1.,0.17);
	pad2->SetBottomMargin(0.1);
	pad2->SetTopMargin(0.009571988);
	pad2->Draw();
	pad2->cd();
	pad2->SetLogx();
       	pad2->DrawFrame(0.0001,-0.443,1,0.455);
	hframe->GetYaxis()->SetLabelSize(0.08); 
	hframe->GetXaxis()->SetLabelSize(0.08); 
	hframe->GetYaxis()->SetLabelFont(42); 
	hframe->GetXaxis()->SetLabelFont(42); 

       	g_p_MC_rel->Draw();
       	g_m_MC_rel->Draw("SAME");
       	g_shade_MC_rel->Draw("SAMEf");
	g_shade_MC_rel->GetYaxis()->SetLabelSize(0.1);
	g_shade_MC_rel->GetXaxis()->SetTitle("x");
	
	pad1->Modified();
	pad2->Update();

	g_p_MC_rel->Write();
       	g_m_MC_rel->Write();
       	g_shade_MC_rel->Write();
	
	g->Write();
	g_MC->Write();
	g_p_MC->Write();
	g_m_MC->Write();
       	g_shade_MC->Write();

	
	c2->Print("c2.pdf");
	
	c1->Print("c1.pdf");


}
