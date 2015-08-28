#!/bin/bash

BASE=/nfs/dust/cms/user/eren/pbs/InclJets/Plotting
MC_path=/nfs/dust/cms/user/eren/pbs/HERA2/MC_method
echo "This script is for calculating experimental, model and parametrisation uncertainty for each flavor and Q2"
echo "Please enter 4 parameters. 1st one is scale, 2nd is pdf type number, 3rd is string and 4th is experiment"
echo "PDF Type : Gluon : 2, u_v : 7, d_v : 8."
echo "Example : 01 2 g hera"
read scale flavor string exp

case $scale in
"01") 
	real_scale=$(echo "1.9")
	;;
"02")
	real_scale=$(echo "10.0")
	;;
"03")
	real_scale=$(echo "100.0")
	;;
"04")
	real_scale=$(echo "1000.0")
	;;
"05")
	real_scale=$(echo "10000.0")
	;;
"06")
	real_scale=$(echo "100000.0")
esac

echo "The scale you have chosen (GeV^2): " $real_scale 

MCMethod (){
if [ $4 == "hera" ]; then
	ls -ltrh $MC_path | grep 18pHERAII_replica | awk '{print $9}' > files_mc
	cat $MC_path/18pHERAII_replica_1/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_$1
else
	ls -ltrh $MC_path | grep 18pHERAII+CMS | awk '{print $9}' > files_mc
	cat $MC_path/18pHERAII+CMS_replica_1/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_$1
fi

cat hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$1_center_$3

for i in $(cat files_mc);do
	cat $MC_path/$i/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$i	
done

paste -d ' ' tmp_x_$1 tmp_$1_center_$3 tmp_18pHERA* > MC.$3.full.txt

rm tmp_18pHERA*
rm mc_rms mc_mean mc_sq
touch mc_rms mc_mean mc_sq

for j in `seq 1 101`;do 
	cat MC.$3.full.txt | sed -n ''$j'p' | awk '{s=0; for(i=3;i<=NF; i++) s=s+$i; print s/(NF-2)}' >> mc_mean 
	cat MC.$3.full.txt | sed -n ''$j'p' | awk '{s=0; for(i=3;i<=NF; i++) s=s+($i^2); print s/(NF-2)}' >> mc_sq 
	
done  

paste -d ' ' mc_sq mc_mean | awk '{print sqrt($1-($2*$2))}' > mc_sigma  
paste -d ' ' mc_sq | awk '{print sqrt($1)}' > mc_RMS  

#paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_RMS | awk '{print $1,$2,($2+$3),($2-$3)}' > MC.$3.txt
paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_sigma | awk '{print $1,$2,($2+$3),($2-$3)}' > MC.$3.txt

paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_sigma | awk '{print $1,$2,($3/$2),(-1)*($3/$2)}' > MC.$3.relative.txt
#paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_RMS | awk '{print $1,$2,($3/$2),(-1)*($3/$2)}' > MC.$3.relative.txt
rm tmp_x_$1 
rm tmp_$1_center_$3

}


GetExpUnc (){
# $1 = Q2
# $2 = pdf type --Field
# $3 = pdf type --String 
# example : GetExpUnc 02 5 uv
cd hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output
#cd hera2_only-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.10:50:24-08-10-2015/output

for i in {01..18};do
   touch $3_$i plus_$i pdiff_$3_$i mdiff_$3_$i
   cat pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > $3_$i
   cat pdfs_q2val_s"$i"p_$1.txt | awk '{print $'$2'}' | tail -n +3 > plus_$i
   cat pdfs_q2val_s"$i"m_$1.txt | awk '{print $'$2'}' | tail -n +3 > minus_$i
   paste $3_$i plus_$i minus_$i | awk '{if ($2 > $3) print $2; else print $3}' > tmp_max  
   paste $3_$i plus_$i minus_$i | awk '{if ($2 > $3) print $3; else print $2}' > tmp_min  
  
   paste tmp_max $3_$i | awk '{print $1,$2}' | awk '{dif=$1-$2; printf "%.17f\n", dif}' > pdiff_$3_$i  
   paste tmp_min $3_$i | awk '{print $1,$2}' | awk '{dif=$2-$1; printf "%.17f\n", dif}' > mdiff_$3_$i  
   
   rm $3_$i 
   rm plus_$i 
   rm minus_$i 
done


paste -d ' ' *mdiff* > $3_18source_m 
paste -d ' ' *pdiff* > $3_18source_p
rm mdiff*
rm pdiff*

cat $3_18source_m | awk '{sum = ($1^2)+($2^2)+($3^2)+($4^2)+($5^2)+($6^2)+($7^2)+($8^2)+($9^2)+($10^2)+($11^2)+($12^2)+($13^2)+($14^2)+($15^2)+($16^2)+($17^2)+($18^2); printf "%.17f\n", sum}' | awk '{ sq=sqrt($1);  printf "%.17f\n", sq}'  > $3_minus
cat $3_18source_p | awk '{sum = ($1^2)+($2^2)+($3^2)+($4^2)+($5^2)+($6^2)+($7^2)+($8^2)+($9^2)+($10^2)+($11^2)+($12^2)+($13^2)+($14^2)+($15^2)+($16^2)+($17^2)+($18^2); printf "%.17f\n", sum}' | awk '{ sq=sqrt($1);  printf "%.17f\n", sq}' > $3_plus

cat pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp
paste tmp $3_plus $3_minus | awk '{i=$1;j=$1+$2;k=$1-$3; printf "%.17f\t%.17f\t%.17f\n", i,j,k}' > tmp_2.txt

cat pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > x
paste x tmp $3_plus $3_minus | awk '{i=$1;j=$2;k=($3/$2);l=(-1)*($4/$2); printf "%.17f\t%.17f\t%.17f\t%.17f\n",i,j,k,l}' > $3.relative.exp.txt 

paste x tmp_2.txt | awk '{print $1,$2,$3,$4}' > $3.txt
rm tmp tmp_2.txt x
cd $BASE
}

GetParUnc (){
   cat hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$3-$1_center 
   cat hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_center 
   paste tmp_x_center tmp_$3-$1_center | awk '{print $1,$2}' > ParaUncert/tmp_total
   rm tmp_$3-$1_center tmp_x_center
   cd ParaUncert
   ls -ltrh | grep hera2 |  awk '{print $9}' > tmp_list
   for i in $(cat tmp_list);do
	cat $BASE/ParaUncert/$i/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$i 
   done 
   paste -d ' ' tmp_hera2* > all_param
   for j in `seq 1 101`;do
	cat $BASE/ParaUncert/all_param | sed -n ''$j'p' > tmp_lines
	for i in $(cat tmp_lines);do echo $i;done | sort -n | tail -1 >> tmp_max
	for k in $(cat tmp_lines);do echo $k;done | sort -n | head -1 >> tmp_min
	rm tmp_lines 
   done 
   
   paste -d ' ' tmp_total tmp_max tmp_min > $3_para.txt
   #paste -d ' ' tmp_total all_param > total
   
   cat $3_para.txt | awk '{print ($3-$2)}' > para_plus 
   cat $3_para.txt | awk '{print ($2-$4)}' > para_minus 
   paste -d ' ' $BASE/ModelUncert/exp_model_p para_plus | awk '{print ($1^2)+($2^2)}' | awk '{print sqrt($1)}' > exp_model_para_p 
   paste -d ' ' $BASE/ModelUncert/exp_model_m para_minus | awk '{print ($1^2)+($2^2)}' | awk '{print sqrt($1)}' > exp_model_para_m 
   paste tmp_total exp_model_para_p exp_model_para_m | awk '{print $1,$2,($3/$2),(-1)*($4/$2)}' > $3.relative.para.txt 
   paste tmp_total exp_model_para_p exp_model_para_m | awk '{print $1,$2,($2+$3),($2-$3)}' > $3_para.txt
   mv $3_para.txt ../
   rm tmp_*
   cd $BASE
}

GetModelUnc (){
   cat hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$3-$1_center 
   cat hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_center 
   paste tmp_x_center tmp_$3-$1_center | awk '{print $1,$2}' > ModelUncert/tmp_total
   cd ModelUncert
   rm model_*   
 
   for i in $(cat list);do
   	UP=$(ls -ltrh | grep Up | grep $i | awk '{print $9}')
   	DOWN=$(ls -ltrh | grep Down | grep $i | awk '{print $9}')
	cat $BASE/ModelUncert/$UP/output/pdfs_q2val_$1.txt | tail -n +3 | awk '{print $'$2'}' > tmp_up_$i
   	cat $BASE/ModelUncert/$DOWN/output/pdfs_q2val_$1.txt | tail -n +3 | awk '{print $'$2'}' > tmp_down_$i
	paste $BASE/tmp_$3-$1_center tmp_up_$i tmp_down_$i | awk '{print $1,$2,$3}' > tmp_three_col_$i
	rm tmp_up_$i tmp_down_$i
  	touch tmp_max tmp_min
	for j in `seq 1 101`;do
		cat tmp_three_col_$i | sed -n ''$j'p' > tmp_lines
		for l in $(cat tmp_lines);do echo $l;done | sort -n | tail -1 >> tmp_max
		for k in $(cat tmp_lines);do echo $k;done | sort -n | head -1 >> tmp_min
		
   	done 
       
	paste -d ' ' tmp_three_col_$i tmp_max tmp_min | awk '{print $1,$2,$3,$4,$5}' > model_$i
   	cat model_$i | awk '{print ($4-$1)}' > model_plus_$i
   	cat model_$i | awk '{print ($1-$5)}' > model_minus_$i
	rm tmp_max tmp_min
   done

   	
  


   paste model_plus_* | awk '{print $1,$2,$3,$4}' | awk '{print ($1^2)+($2^2)+($3^2)+($4^2)}' | awk '{print sqrt($1)}' > model_p
   paste model_minus_* | awk '{print $1,$2,$3,$4}' | awk '{print ($1^2)+($2^2)+($3^2)+($4^2)}' | awk '{print sqrt($1)}' > model_m

   paste model_p $BASE/hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/$3_plus | awk '{print ($1^2)+($2^2)}' | awk '{print sqrt($1)}' > exp_model_p    
   paste model_m $BASE/hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015/output/$3_minus | awk '{print ($1^2)+($2^2)}' | awk '{print sqrt($1)}' > exp_model_m    
   

   paste $BASE/ModelUncert/tmp_total exp_model_p exp_model_m | awk '{print $1,$2,($3/$2),(-1.0)*($4/$2)}' > $3.relative.model.txt 
   paste $BASE/ModelUncert/tmp_total exp_model_p exp_model_m | awk '{print $1,$2,($2+$3),($2-$4)}' > $3_model.txt	

   mv $3_model.txt ../
   rm tmp*
   #rm model_p model_m
   cd $BASE
      

}

#GetExpUnc 01 2 g
MCMethod $scale $flavor $string $exp
GetExpUnc $scale $flavor $string
GetModelUnc $scale $flavor $string 
GetParUnc $scale $flavor $string 

EXP_num=$(cat draw_pdf.C | grep -n file.open | awk '{print $1}' | cut -d : -f1)
YAXIS_num=$(cat draw_pdf.C | grep -n GetYaxis | awk '{print $1}' | cut -d : -f1) 
TFILE_num=$(cat draw_pdf.C | grep -n TFile | awk '{print $1}' | cut -d : -f1) 

MAX_num=$(cat plot_super.C | grep -n SetMaximum | awk '{print $1}' | cut -d : -f1) 

MODEL_num=$(cat draw_pdf.C | grep -n file.open | awk '{print $1}' | cut -d : -f1)

cp draw_pdf.C draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015\/output\/'$string'.txt\")\;/' draw_pdf_$string.C
#sed -i ''$PDF_num's/.*/\tc1->Print(\"'$string'.pdf\")\;/' draw_pdf_$string.C
sed -i ''$YAXIS_num's/.*/\tgr->GetYaxis()->SetTitle(\"x.'$string'(x,Q^{2})")\;/' draw_pdf_$string.C


root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"'$string'_model.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center/Center_model/' draw_pdf_$string.C
sed -i 's/Plus/Plus_model/' draw_pdf_$string.C
sed -i 's/Minus/Minus_model/' draw_pdf_$string.C
sed -i 's/Shade/Shade_model/' draw_pdf_$string.C

root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"'$string'_para.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center_model/Center_para/' draw_pdf_$string.C
sed -i 's/Plus_model/Plus_para/' draw_pdf_$string.C
sed -i 's/Minus_model/Minus_para/' draw_pdf_$string.C
sed -i 's/Shade_model/Shade_para/' draw_pdf_$string.C


root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"MC.'$string'.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center_para/Center_MC/' draw_pdf_$string.C
sed -i 's/Plus_para/Plus_MC/' draw_pdf_$string.C
sed -i 's/Minus_para/Minus_MC/' draw_pdf_$string.C
sed -i 's/Shade_para/Shade_MC/' draw_pdf_$string.C

root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"MC.'$string'.relative.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center_MC/Center_MC_rel/' draw_pdf_$string.C
sed -i 's/Plus_MC/Plus_MC_rel/' draw_pdf_$string.C
sed -i 's/Minus_MC/Minus_MC_rel/' draw_pdf_$string.C
sed -i 's/Shade_MC/Shade_MC_rel/' draw_pdf_$string.C


root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"hera2_cms8TeV-10p+NeG+DUbar+Eg+Duv+Ddv+EDbar+DDbar_BANDS.11:32:29-08-07-2015\/output\/'$string'.relative.exp.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center_MC_rel/Center_EXP_rel/' draw_pdf_$string.C
sed -i 's/Plus_MC_rel/Plus_EXP_rel/' draw_pdf_$string.C
sed -i 's/Minus_MC_rel/Minus_EXP_rel/' draw_pdf_$string.C
sed -i 's/Shade_MC_rel/Shade_EXP_rel/' draw_pdf_$string.C


root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"ModelUncert\/'$string'.relative.model.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center_EXP_rel/Center_MODEL_rel/' draw_pdf_$string.C
sed -i 's/Plus_EXP_rel/Plus_MODEL_rel/' draw_pdf_$string.C
sed -i 's/Minus_EXP_rel/Minus_MODEL_rel/' draw_pdf_$string.C
sed -i 's/Shade_EXP_rel/Shade_MODEL_rel/' draw_pdf_$string.C

root -l -q draw_pdf_$string.C

sed -i ''$TFILE_num's/.*/\tTFile *f = new TFile(\"plots.root\",\"UPDATE\")\;/' draw_pdf_$string.C
sed -i ''$EXP_num's/.*/\tfile.open(\"ParaUncert\/'$string'.relative.para.txt\")\;/' draw_pdf_$string.C
sed -i 's/Center_MODEL_rel/Center_PARA_rel/' draw_pdf_$string.C
sed -i 's/Plus_MODEL_rel/Plus_PARA_rel/' draw_pdf_$string.C
sed -i 's/Minus_MODEL_rel/Minus_PARA_rel/' draw_pdf_$string.C
sed -i 's/Shade_MODEL_rel/Shade_PARA_rel/' draw_pdf_$string.C


root -l -q draw_pdf_$string.C

LABEL_num_tx=$(cat plot_super.C | grep -n "CMS NLO" | grep tx | awk '{print $1}' | cut -d : -f1)
LABEL_num_tx2=$(cat plot_super.C | grep -n tx2 | grep TLatex | awk '{print $1}' | cut -d : -f1)

case "$string" in
"dv")
	sed -i ''$MAX_num's/.*/g->SetMaximum(0.6)\;/' plot_super.C
	sed -i ''$LABEL_num_tx's/.*/TLatex \*tx = new TLatex(0.0001129711,0.6,\"CMS NLO\")\;/' plot_super.C
	sed -i ''$LABEL_num_tx2's/.*/TLatex \*tx2 = new TLatex(0.04921771,0.5811539,\"Q^{2}='$real_scale' GeV^{2}\")\;/' plot_super.C

;;
"g")
	if [ $scale -eq "05" ] || [ $scale -eq "04" ];then
		sed -i ''$MAX_num's/.*/g->SetMaximum(60)\;/' plot_super.C
		sed -i ''$LABEL_num_tx's/.*/TLatex \*tx = new TLatex(0.0001129711,60.835391,\"CMS NLO\")\;/' plot_super.C
		sed -i ''$LABEL_num_tx2's/.*/TLatex \*tx2 = new TLatex(0.03921771,57.105647,\"Q^{2}='$real_scale' GeV^{2}\")\;/' plot_super.C

	else
		sed -i ''$MAX_num's/.*/g->SetMaximum(4.5)\;/' plot_super.C
		sed -i ''$LABEL_num_tx's/.*/TLatex \*tx = new TLatex(0.0001129711,4.535391,\"CMS NLO\")\;/' plot_super.C
		sed -i ''$LABEL_num_tx2's/.*/TLatex \*tx2 = new TLatex(0.04921771,4.105647,\"Q^{2}='$real_scale' GeV^{2}\")\;/' plot_super.C
	fi
	

;;
"uv")
	sed -i ''$MAX_num's/.*/g->SetMaximum(1.0)\;/' plot_super.C
	sed -i ''$LABEL_num_tx's/.*/TLatex \*tx = new TLatex(0.0001129711,1.011866,\"CMS NLO\")\;/' plot_super.C
	sed -i ''$LABEL_num_tx2's/.*/TLatex \*tx2 = new TLatex(0.04921771,0.8811539,\"Q^{2}='$real_scale' GeV^{2}\")\;/' plot_super.C
	
;;

esac

if [ $exp == "hera" ]; then
	sed -i '4s/.*/TFile \*f = new TFile(\"MC.hera.'$string'.'$scale'.root\",\"recreate\")\;/' plot_super.C
else
	sed -i '4s/.*/TFile \*f = new TFile(\"MC.hera+CMS.'$string'.'$scale'.root\",\"recreate\")\;/' plot_super.C
fi

root -l -q plot_super.C


mv c1.pdf $string.$scale.pdf
mv c2.pdf $string.$scale.MC_18p.pdf

mv $string.$scale.pdf plots/
mv $string.$scale.MC_18p.pdf plots/

evince plots/$string.$scale.pdf 
evince plots/$string.$scale.MC_18p.pdf 
#evince plots/$string.$scale.MC_rel.pdf 
 

exit 0;


