#!/bin/bash

BASE=/nfs/dust/cms/user/eren/pbs/WA/Plotting
MC_path=/nfs/dust/cms/user/eren/pbs/WA/MC_method
echo "This script is for calculating experimental, model and parametrisation uncertainty for each flavor and Q2"
echo "Please enter 4 parameters. 1st one is scale, 2nd is pdf type number, 3rd is string and 4th is experiment"
echo "PDF Type : Gluon : 2, u_v : 7, d_v : 8."
echo "Example : 01 2 g hera"
read scale flavor string exp


MCMethod (){
if [ $4 == "hera" ]; then
	ls -ltrh $MC_path | grep 13pHERAII_replica_ | awk '{print $9}' > files_mc
else
	ls -ltrh $MC_path | grep 13pHERAII+CMS | awk '{print $9}' > files_mc
fi

cat $MC_path/13pHERAII+CMS_WAsym_replica_74/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_$1
cat WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$1_center_$3

for i in $(cat files_mc);do
	cat $MC_path/$i/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$i	
done

paste -d ' ' tmp_x_$1 tmp_$1_center_$3 tmp_13pHERA* > MC.$3.full.txt

rm tmp_13pHERA*
rm mc_rms mc_mean mc_sq
touch mc_rms mc_mean mc_sq

for j in `seq 1 101`;do 
	cat MC.$3.full.txt | sed -n ''$j'p' | awk '{s=0; for(i=3;i<=NF; i++) s=s+$i; print s/(NF-2)}' >> mc_mean 
	cat MC.$3.full.txt | sed -n ''$j'p' | awk '{s=0; for(i=3;i<=NF; i++) s=s+($i^2); print s/(NF-2)}' >> mc_sq 
	
done  

paste -d ' ' mc_sq mc_mean | awk '{print sqrt($1-($2*$2))}' > mc_sigma  
#paste -d ' ' mc_sq | awk '{print sqrt($1)}' > mc_sigma  

#paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_rms | awk '{print $1,$2,($2+$3),($2-$3)}' > MC.$3.txt
paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_sigma | awk '{print $1,$2,($2+$3),($2-$3)}' > MC.$3.txt

paste -d ' ' tmp_x_$1 tmp_$1_center_$3 mc_sigma | awk '{print $1,$2,($3/$2),(-1)*($3/$2)}' > MC.$3.relative.txt
rm tmp_x_$1 
rm tmp_$1_center_$3

}


GetExpUnc (){
# $1 = Q2
# $2 = pdf type --Field
# $3 = pdf type --String 
# example : GetExpUnc 02 5 uv
cd WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output 

ls -ltrh | grep pdfs_ | grep pdfs_q2val_s | grep p_$1 |  awk '{print $9}' > pdf_list_p
ls -ltrh | grep pdfs_ | grep pdfs_q2val_s | grep m_$1 |  awk '{print $9}' > pdf_list_m


for i in $(cat pdf_list_p);do
   touch $3_$i plus_$i pdiff_$3_$i
   cat pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > $3_$i
   cat $i | awk '{print $'$2'}' | tail -n +3 > plus_$i
   paste plus_$i $3_$i | awk '{print $1,$2}' | awk '{print ($1-$2)}' > pdiff_$3_$i  
   rm $3_$i 
   rm plus_$i 
done

for j in $(cat pdf_list_m);do
   touch $3_$j minus_$j mdiff_$3_$j
   cat pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > $3_$j
   cat $j | awk '{print $'$2'}' | tail -n +3 > minus_$j
   paste minus_$j $3_$j | awk '{print $1,$2}' | awk '{print ($2-$1)}' > mdiff_$3_$j  
   rm $3_$j 
   rm minus_$j 
done

paste -d ' ' *mdiff* > $3_13source_m 
paste -d ' ' *pdiff* > $3_13source_p
rm mdiff*
rm pdiff*

cat $3_13source_m | awk '{print ($1^2)+($2^2)+($3^2)+($4^2)+($5^2)+($6^2)+($7^2)+($8^2)+($9^2)+($10^2)+($11^2)+($12^2)+($13^2)}' | awk '{print sqrt($1)}' > $3_minus
cat $3_13source_p | awk '{print ($1^2)+($2^2)+($3^2)+($4^2)+($5^2)+($6^2)+($7^2)+($8^2)+($9^2)+($10^2)+($11^2)+($12^2)+($13^2)}' | awk '{print sqrt($1)}' > $3_plus

cat pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp
paste tmp $3_plus $3_minus | awk '{print $1,($1+$2),($1-$3)}' > tmp_2.txt
cat pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > x
paste x tmp_2.txt | awk '{print $1,$2,$3,$4}' > $3.txt
rm tmp tmp_2.txt x
cd $BASE
}

GetParUnc (){
   cat WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$3-$1_center 
   cat WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_center 
   paste tmp_x_center tmp_$3-$1_center | awk '{print $1,$2}' > ParaUncert/tmp_total
   rm tmp_$3-$1_center tmp_x_center
   cd ParaUncert
   ls -ltrh | grep WA |  awk '{print $9}' > tmp_list
   for i in $(cat tmp_list);do
	cat $BASE/ParaUncert/$i/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$i 
   done 
   paste -d ' ' tmp_WA* > all_param
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
   paste tmp_total exp_model_para_p exp_model_para_m | awk '{print $1,$2,($2+$3),($2-$3)}' > $3_para.txt
   mv $3_para.txt ../
   rm tmp_*
   cd $BASE
}

GetModelUnc (){
   cat WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/pdfs_q2val_$1.txt | awk '{print $'$2'}' | tail -n +3 > tmp_$3-$1_center 
   cat WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/pdfs_q2val_$1.txt | awk '{print $1}' | tail -n +3 > tmp_x_center 
   paste tmp_x_center tmp_$3-$1_center | awk '{print $1,$2}' > ModelUncert/tmp_total
   cd ModelUncert
   
   for i in $(cat list);do
   	UP=$(ls -ltrh up | grep $i | awk '{print $9}')
   	DOWN=$(ls -ltrh down | grep $i | awk '{print $9}')
	cat $BASE/ModelUncert/up/$UP/output/pdfs_q2val_$1.txt | tail -n +3 | awk '{print $'$2'}' > tmp_up_$i
   	cat $BASE/ModelUncert/down/$DOWN/output/pdfs_q2val_$1.txt | tail -n +3 | awk '{print $'$2'}' > tmp_down_$i
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

   paste model_p $BASE/WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/$3_plus | awk '{print ($1^2)+($2^2)}' | awk '{print sqrt($1)}' > exp_model_p    
   paste model_m $BASE/WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015/output/$3_minus | awk '{print ($1^2)+($2^2)}' | awk '{print sqrt($1)}' > exp_model_m    
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
sed -i ''$EXP_num's/.*/\tfile.open(\"WAsymm-8TeV-10p+Dg+Bdv+EUbar_BANDS.16:26:02-06-30-2015\/output\/'$string'.txt\")\;/' draw_pdf_$string.C
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

case "$string" in
"dv")
	sed -i ''$MAX_num's/.*/g->SetMaximum(0.6)\;/' plot_super.C
;;
"g")
	if [ $scale -eq "05" ] || [ $scale -eq "04" ];then
		sed -i ''$MAX_num's/.*/g->SetMaximum(60)\;/' plot_super.C
	else
		sed -i ''$MAX_num's/.*/g->SetMaximum(4.5)\;/' plot_super.C
	fi
;;
"uv")
	sed -i ''$MAX_num's/.*/g->SetMaximum(1.0)\;/' plot_super.C
;;

esac

if [ $exp == "hera" ]; then
	sed -i '4s/.*/TFile \*f = new TFile(\"MC.hera.'$string'.'$scale'.root\",\"recreate\")\;/' plot_super.C
else
	sed -i '4s/.*/TFile \*f = new TFile(\"MC.hera+CMS.'$string'.'$scale'.root\",\"recreate\")\;/' plot_super.C
fi

root -l -q plot_super.C


mv c1.pdf $string.$scale.pdf
mv c2.pdf $string.$scale.MC_13p.pdf

mv $string.$scale.pdf plots/
mv $string.$scale.MC_13p.pdf plots/

#evince plots/$string.$scale.pdf 
#evince plots/$string.$scale.MC_heraOnly.pdf 
#evince plots/$string.$scale.MC_rel.pdf 
 

exit 0;

