void drawFrame(){
    //图形框架
    drawMainFrame();
    drawConventionalSigns();
    drawHospital(borderWidth,height-2*borderWidth,int((height/2-borderWidth)),int(1.5*borderWidth),bedsCount);
    drawDeathFrame(borderWidth+height/2-borderWidth,height-2*borderWidth,int((height/2-borderWidth)),int(1.5*borderWidth),deathCount);
    int axisBorderWidth=borderWidth;
    //人口流动取值范围是(0，100)，床位取值范围(0,初始感染人数),dy的取值需要用y的函数数据再跑一次，processing里拼合
    drawAxis(height+axisBorderWidth,axisBorderWidth,width-height-2*axisBorderWidth,height/2-2*axisBorderWidth,100,12.5,10,4,"流动人口比例","样本死亡率");
  
}
//绘制主框架
void drawMainFrame(){
    stroke(lines);
    rect(0, 0, height, height-1);//city frame
    fill(bg);
    rect(height, 0, width-height-1, height/2);//y frame
    rect(height, height/2, width-height-1, height-1);//dy frame
    rect(borderWidth,height-2*borderWidth, (height-2*borderWidth)/2, 1.5*borderWidth);//病床 frame
    rect(borderWidth+height/2-borderWidth,height-2*borderWidth, (height-2*borderWidth)/2, 1.5*borderWidth);//死亡 frame
    
    textFont(font);
    textSize(15);
    textAlign(RIGHT, BOTTOM);
    fill(lines);
    text("人群状态", height-borderWidth, height-2.3*borderWidth);
    text("y函数图", width, height/2);
    text("dy函数图", width, height);
    text("空余床位数="+(bedsTotal -bedsCount), (height)/2, height);
    text("样本死亡率="+ int(float(10000*deathCount/totalPopulation))/100.00+"%", height-borderWidth, height);
    textAlign(LEFT, TOP);
    text("流动人口比例="+flowRate+"%",borderWidth,1.5*borderWidth);
    text("床位充足率="+int(float(100*bedsTotal)/patients)+"%",borderWidth,2*borderWidth);
    noFill();
}

//绘制图例
void drawConventionalSigns(){
    int csWeight=height-2*borderWidth;
    StringList signNameList;
    signNameList = new StringList();
    signNameList.append("未感染人数");
    signNameList.append("潜伏人数");
    signNameList.append("确诊人数");
    signNameList.append("治愈人数");
    signNameList.append("死亡人数");
    int signNumbers=signNameList.size();
    IntList signColorList;
    signColorList = new IntList();
    signColorList.append(sColor);
    signColorList.append(shadowColor);
    signColorList.append(iColor);
    signColorList.append(rColor);
    signColorList.append(dColor);
    IntList countList;
    countList = new IntList();
    countList.append(uninfectedCount);
    countList.append(infectedCount);
    countList.append(confirmedCount);
    countList.append(curedCount);
    countList.append(deathCount);
    int eachSignWeight=csWeight/signNumbers;
    // println(countList);

    int locationy=50;
    int signIconSize=15;
    int proportionStartLocation=borderWidth;
    int proportionLocationy=locationy+signIconSize+10;
    for (int i = 0; i < signNumbers ; ++i) {
        int locationx=borderWidth+i*eachSignWeight;
        drawEachSigns(locationx,locationy,eachSignWeight,signIconSize,signNameList.get(i),signColorList.get(i),countList.get(i));
        // drawProportionBar(proportionStartLocation,proportionLocationy,height-2*borderWidth,signColorList.get(i),countList.get(i));        
    }
    
}
void drawEachSigns(int locationx,int locationy,int eachSignWeight,int signIconSize,String signName,color signsColor,int counts){
    fill(signsColor);
    rect(locationx, locationy, signIconSize, signIconSize);
    noFill();
    textFont(font);
    textAlign(LEFT, BOTTOM);
    fill(lines);
    text((signName+"="+counts),locationx+20,locationy+signIconSize+3);
    noFill();
}

//这段进度条好像有点问题
void drawProportionBar(int proportionLocationx,int proportionLocationy,int proportionBarWeight,color signsColor,int counts){
    fill(signsColor);
    rect(proportionLocationx, proportionLocationy, (proportionBarWeight*counts)/cutA, 10);
    noFill();
    proportionStartLocation+=proportionBarWeight*counts/cutA;
}


void drawHospital(int locationx,int locationy,int widthHospital,int heightHospital ,int bedsCount){
    float p = abs(widthHospital/heightHospital);
    int linex=int(sqrt(bedsTotal*p))+1;
    int liney=int(sqrt(bedsTotal/p))+1;
    float dx=widthHospital/(linex);
    float dy=heightHospital/(liney);
    // println(widthHospital,heightHospital,p,linex,liney,dx,dy,bedsTotal);
    int drawBedsHospitalized=0;
    //画床位
    for (int x = 0; x < linex; ++x) {
        float pointx=x*dx+0.5*dx;
        for (int y = 0; y < liney; ++y) {
            float pointy=y*dy+0.5*dy;
            if (drawBedsHospitalized<bedsCount) {
                drawBedsHospitalized+=1;
                stroke(iColor);
                strokeWeight(2*strokeWeightMul);
                point(locationx+pointx,locationy+pointy);
                strokeWeight(strokeWeightMul);            
            } 
        }
    }
}

void drawDeathFrame(int locationx,int locationy,int widthDeathFrame,int heightDeathFrame ,int deathCount){
    float p = abs(widthDeathFrame/heightDeathFrame);
    int linex=int(sqrt(2*patients*0.01*deathRateNature*p))+1;
    int liney=int(sqrt(2*patients*0.01*deathRateNature/p))+1;
    float dx=widthDeathFrame/(linex);
    float dy=heightDeathFrame/(liney);
    // println(widthDeathFrame,heightDeathFrame,p,linex,liney,dx,dy,bedsTotal);
    int drawDeathFrame=0;
    //画床位
    for (int x = 0; x < linex; ++x) {
        float pointx=x*dx+0.7*dx;
        for (int y = 0; y < liney; ++y) {
            float pointy=y*dy+0.7*dy;
            if (drawDeathFrame<deathCount) {
                drawDeathFrame+=1;
                stroke(sColor);
                strokeWeight(2*strokeWeightMul);
                point(locationx+pointx,locationy+pointy);
                strokeWeight(strokeWeightMul);            
            } 
        }
    }
}

void drawAxis(int locationx,int locationy,int widthAxis,int heightAxis,float xRange,float yRange,int xPer,int yPer,String xName,String yName){
    stroke(lines);
    int axisStickWidth=6;
    line(locationx, locationy, locationx, locationy+heightAxis);//yAxis
    textAlign(CENTER, BOTTOM);
    text(yName,locationx,locationy-10);
    for (int p = 0; p <= yPer; ++p) {
        line(locationx-axisStickWidth, locationy+p*(heightAxis/yPer), locationx+axisStickWidth, locationy+p*(heightAxis/yPer));
        textAlign(RIGHT, CENTER);
        text(yRange-p*yRange/yPer,locationx-axisStickWidth, locationy+p*heightAxis/yPer);
    }

    line(locationx, locationy+widthAxis, locationx+widthAxis, locationy+widthAxis);//xAxis
    textAlign(CENTER, BOTTOM);
    text(xName,locationx+widthAxis,locationy+heightAxis-10);
    for (int p = 0; p <= xPer; ++p) {
        line(locationx+widthAxis-p*widthAxis/xPer, locationy+widthAxis-axisStickWidth,locationx+widthAxis-p*widthAxis/xPer,locationy+widthAxis+axisStickWidth );
        textAlign(CENTER, TOP);
        text(floor(xRange-p*xRange/xPer),locationx+widthAxis-p*widthAxis/xPer,locationy+widthAxis+axisStickWidth );
    }
    

}