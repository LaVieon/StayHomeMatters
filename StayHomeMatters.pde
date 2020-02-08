ArrayList<Agent> people; //<>// //<>//
//框架相关变量声明
int[] pixel_list;
color lines = #FFFFFF;
color sColor = #FFFFFF;//未感染颜色
color shadowColor = #ffB362;//潜伏期颜色
color iColor = #e10000;//发病颜色
color rColor = #34cc70;//被治愈颜色
color dColor = #000000;//死亡颜色
color bg=#333333;
int borderWidth=50;
int strokeWeightMul=2;
int proportionStartLocation=borderWidth;
PFont font;
//疫情发展相关变量声明
int totalPopulation = 2000 ;//总模型人数
int patients= 300;//初始感染人数
int flowRate = 70;//人口流动比例
int bedsTotal = 45;//病床数量
int bedsCount=0;//病床计数器
int deathCount;//死亡人数计数器
int deathCountPast;
int healthPeopleCount;
int uninfectedCount;
int infectedCount;
int confirmedCount;
int curedCount;


//疫情模型相关变量声明
int worldTime=0;//世界时间
int density=100;//城市密集程度
int cutA=0;//粒子数量统计
int spreadDist=2;//传染距离
float spreadProbability=0.8;//传染概率
float deathRateHospital=2.3;//医院死亡率
int deathRateNature=40;//自然死亡率

//粒子state状态变量声明，参考B站(回形针PaperClip)
int NORMAL = 0;//未感染状态码
int INFECTED = 5;//潜伏期时间
int CONFIRMED = 10;//确诊时间
int REMOVAL=20;//全部病程时间
int CURED = 1024;//状态码
int DEAD = 4444;


int generation=0;
int mode=0;//0是人口流动变量模式，1是床位变量模式
Table table;
int genboolen=0;
boolean isInit = false;
float bedsIter=bedsTotal;


void setup() {
  size(1200, 800);
  frameRate(30);
  background(bg);
  noFill();
  font = createFont("STXIHEI.TTF",15);
  // strokeWeight(1);

  // 初次建立表格
  // table=new Table();  
  // table.addColumn("id");
  // table.addColumn("flowRate");
  // table.addColumn("deathRateTotal");
  table = loadTable("mytable.csv","header");
  init();
  

  generation+=1;
  println("generation=",generation);
  

}
void init(){
  genPeople();
  initPatents();
}


// void choiceMode(int mode){
//   if (mode==0) {
//     if (flowRate<80) {
//       println("exit for flowRate");
//       exit(); 
//     }
//     if (flowRate>=0 && flowRate <=100 && generation!=genboolen) {
//       // init();
//         genPeople();
//     initPatents();
//     genboolen=generation;
      
      
//     }
//   }else if (mode==1) {
//     bedsTotal=patients;
//     if (bedsTotal>=0 && bedsTotal <100) {
//       bedsTotal-= floor(patients/10);
//     }
//     if (bedsTotal<0) {
//       exit(); 
//     }
//   }
// }

void runDateFlow(){
  if (flowRate<0) {
    isInit=true;
    runDateBeds();
    // println("exit for flowRate");
    // exit(); 
  }else if (isInit) {
    init();
    isInit=false;
    flowRate-=5;      
  }
}
void runDateBeds(){
  flowRate=100;
  if (bedsTotal<0) {
    println("ALL RIGHT");
    exit();
  }else if (isInit) {
    // generation+=1;
    init();
    isInit=false;
    bedsIter -= patients/20;   
    bedsTotal =round(bedsIter);      
  }


}




void draw() {

  runDateFlow();
  // choiceMode(mode);
  if (generation>=805) {
    println("exit for generation");
    exit();

  }




  background(bg);
  //添加粒子行为
  for (Agent v : people) {
    v.applyBehaviors(people);
    v.applyVirusSpreading(people);
    v.updateState();
    v.updateLocation();
  }
  worldTime+=1;
  // println("worldTime",worldTime,"frameRate=",frameRate);
  counts();
  drawFrame();
  // drawHospital(bedsCount);
  // println(bedsCount,"main frame");
  //saveFrame("outputtotal/F"+flowRate+"B"+bedsTotal+"frames######.png");
  if (infectedCount+confirmedCount==0) {
  println("death count=",deathCount, "health count=",healthPeopleCount,"infected count=",infectedCount,"confirmed count=",confirmedCount);
  println("This Generation COMPLETE",generation);
  saveFrame("outputtotal/F"+flowRate+"B"+bedsTotal+"frames######.png");
  saveMyTable();
  // flowRate-=10;
  isInit=true;
  
  generation+=1;
  init();
  // exit();
  
  }
  
}
void counts(){
  healthPeopleCount=0;
  uninfectedCount=0;
  infectedCount=0;
  confirmedCount=0;
  curedCount=0;
  deathCount=0;
  for (Agent h :people) {
    if (h.state==NORMAL) {
      uninfectedCount+=1;
    }else if (h.state==CURED) {
      curedCount+=1;
    }else if (h.state>NORMAL && h.state<=INFECTED) {
      infectedCount+=1;
    }else if (h.state>INFECTED && h.state<=REMOVAL) {
      confirmedCount+=1;
    }else if (h.state==DEAD) {
      deathCount+=1;
    }
  }
  healthPeopleCount=uninfectedCount+curedCount;
  // //每一代的疫情发展报告
  // if (deathCount != deathCountPast) {
  // println("death count=",deathCount, "health count=",healthPeopleCount,"infected count=",infectedCount,"confirmed count=",confirmedCount);
  // deathCountPast=deathCount;    
  // }

}

void saveMyTable(){
  TableRow newRow =table.addRow();
  newRow.setInt("id",frameCount);
  newRow.setInt("flowRate",flowRate);
  newRow.setInt("beds",bedsTotal);
  newRow.setFloat("deathRateTotal",float(10000*deathCount/totalPopulation));
  newRow.setFloat("uninfected",float(10000*uninfectedCount/totalPopulation));
  saveTable(table,"data/mytable.csv");

}
