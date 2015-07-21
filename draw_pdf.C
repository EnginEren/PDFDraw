{
	//TCanvas *c1 = new TCanvas("c1","Gluon PDF",200,10,700,500);
	//c1->DrawFrame(0,0,1,2.5);
	//c1->SetLogx();
	ifstream file;
	file.open("WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/g.txt");
	const int n = 101;
	TFile *f = new TFile("plots.root","recreate");
	Double_t x[n], y[n], ymax[n], ymin[n];
	for(int i=0; i<n; i++){
		double a,b,p,m;
		file >> a >> b >> p >> m;
		x[i]=a;
		y[i]=b;
		ymax[i]=p;
		ymin[i]=m;

	} 
	
	gr = new TGraph(n,x,y);
	gr->SetName("Center");
	grp = new TGraph(n,x,ymax);	
	grp->SetName("Plus");
	grm = new TGraph(n,x,ymin);	
	grm->SetName("Minus");
   	grshade = new TGraph(2*n);
	grshade->SetName("Shade");	
	for (int j=0;j<n;j++) {
      		grshade->SetPoint(j,x[j],ymax[j]);
      		grshade->SetPoint(n+j,x[n-j-1],ymin[n-j-1]);
   	}
	
	gr->SetTitle("");	
	gr->SetLineWidth(1);
   	gr->SetLineStyle(1);
	gr->GetXaxis()->SetTitle("x");
	grp->GetXaxis()->SetTitle("x");
	gr->GetYaxis()->SetTitle("x.u_{v}(x,Q^{2})");
	gr->Write();
        grp->Write();
	grm->Write();
	grshade->Write();	
	/*
	grshade->SetFillColor(kRed);
	gr->Draw("AC");	
   	grp->Draw("C");
   	grm->Draw("C");
	grshade->Draw("f");
	gr->Draw("SAME");	
	f->Close();	
	//c1->Write();
	//c1->Print("some-pdf.pdf");	
	*/
}
