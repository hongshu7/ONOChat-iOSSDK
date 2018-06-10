//
//  IMLoginViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/10.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMLoginViewController.h"
#import "IMLoginCell.h"
#import "IMLoginModel.h"
#import "UIView+Extension.h"
#import "IMConversationViewController.h"
#import "IMContactViewController.h"
#import "IMGlobalData.h"

@interface IMLoginViewController ()

@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation IMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSMutableArray *dataMutableArray = [NSMutableArray new];
    //登陆数据
    NSArray *tokenArray = [self tokenArray];
    for (int i = 0 ; i < tokenArray.count; i++) {
        IMLoginModel *loginModel = [IMLoginModel new];
        loginModel.token = [tokenArray objectAtIndex:i];
        loginModel.nickname = [NSString stringWithFormat:@"test_%03d",i+1];
        loginModel.avatar = [NSString stringWithFormat:@"http://cdn.jingfu.org/a%03d.jpg",i+1];
        [dataMutableArray addObject:loginModel];
    }
    self.dataArray = [dataMutableArray copy];
    [self.tableView reloadData];
}

#pragma mark - tableView about

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IMLoginCell";
    
    IMLoginCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [IMLoginCell im_loadFromXIB];
    }
    cell.loginModel = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IMLoginModel *loginModel = [self.dataArray objectAtIndex:indexPath.row];
    
    [IMGlobalData sharedData].token = loginModel.token;
    
    [self loginToIMServerWithToken:loginModel.token];
}

- (void)loginToIMServerWithToken:(NSString *)token {
    __weak typeof(self) weakSelf = self;
    [[ONOIMClient sharedClient] loginWithToken:token onSuccess:^(ONOUser *user) {
        NSLog(@"user logined with name:%@", user.nickname);
        [IMGlobalData sharedData].user = user;
        [weakSelf enterChatPage];
    } onError:^(int errorCode, NSString *errorMsg) {
        NSLog(@"user logined with error:%@", errorMsg);
    }];
    
}

- (void)enterChatPage {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"会话"
                                                        image:[[UIImage imageNamed:@"tabbar_icon_chat_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                selectedImage:[[UIImage imageNamed:@"tabbar_icon_chat_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                        image:[[UIImage imageNamed:@"tabbar_icon_contact_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                selectedImage:[[UIImage imageNamed:@"tabbar_icon_contact_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    
    IMConversationViewController *conversationViewController = [[IMConversationViewController alloc] init];
    conversationViewController.tabBarItem = item1;
    UINavigationController *conversationNav = [[UINavigationController alloc] initWithRootViewController:conversationViewController];
    
    
    IMContactViewController *contactViewController = [[IMContactViewController alloc] init];
    contactViewController.tabBarItem = item2;
    UINavigationController *contactNav = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    tabbar.viewControllers = @[conversationNav,contactNav];
    tabbar.selectedIndex = 0;
    window.rootViewController = tabbar;
}


- (NSArray *)tokenArray {
    NSString *tokenString = @"piuvkndw2h3grt95j40szxefb1oy6aqm,6nc1xt3gjw05dvsp247ombeq8aulzy9f,uk8379evp0tsf1nqy2chmia5g4owxjlb,cqu3i4hd0xmvpgsafbyj8n95e2k76rt1,30pvfb6z5qjgtr84soucida9wk2elxm7,26qble3m89dpkag4ozx510yhwcrin7vs,8dme1v2g597kjcrhiqyb0an3fw4olzut,gbdwyqjtu01sxo8akz23mfev4h5ir76l,ntsf9qb8cj2okwhdx0lg34i5pu1zaey6,fa5zu47gesr8ho1idwy2n0kjp6mclx9v,wjnitpdvkm2ql6s870fy15brocgh9u3z,dq9ygsh64mzaj253pxbkifrl7uewvoct,tjpscaxmoylnb2ke0fudv95w47z813hq,61wmtk8hgp3li2bcv7xsn45eqzjuoyad,at3h6u409ovk8sgzi12d7rfpcewbqymj,dfq4v7coumiaepzs891xn2ktwb30yl6g,qd59jatkxroz42hpvilfgswc70yeb316,0r7sw85kub1xe2dtnic43flphqmao9yv,qv3ogrh1mf95iwk6pdl2ens8j7tybac4,w08f35y1ixo4kgnmplr29bdsaq7h6zvc,u0326y9trbzpxwehgdlcmqs1n4iak8ov,ep84yqcvsxtof6rh5izu3ln9md0bj1g2,7o5ewdqtcz0jm14iyvxnlgubhkr8296p,u8qs1v0wkl4z7mgb9pjdthy2ro35ef6x,xjhcnyw5o6l2t8k1pb4a3mdg0vefrqzs,8f60qd32bsa1joik4ucghyr59lnxvpmt,6jyhdke21x3uosmfbw5plqcatvrg7409,s5wyrqz6lxp3oi9dfku40hntmjcg17e2,015gsk2dnvu67y8obc4phfrzq9lwtexa,dy9c0kjwigo2v7b3xp6af4lsu8zqme1r,69mrphgk57ejsclzdxqw12t3o4bu0nfa,nkhrs18ma2wefpbxq6vocg0z97ul4tj5,qleaygdzi2x7b8tp64v53fch0smuwnkj,2fby0sekg3w7qnti4ldpvajmzr58uxh6,kvoqiy3c45tl9rbes1ngu6f7pwah80jz,sipuf0w4x2ejao7gvkctn6qy1m5zbd8r,74nysip0eak83zvmlcfbg9ro5jthqwd6,2gbtlprw1ociu4089nszhy7xmqvjfdk6,0orgzh7mxve4dkfj6wacu253qys9bil8,clry6b8tx9q25hngd71wo03v4akpzumi,xtvghd1mipqncsy6jb2o5kw738zf09l4,zn7dkvroqi3pu1ah9btgs20fm4jwx65l,aestr01pqlkd2bx8fhmyjgou493vizc5,zoik6xmq8l3ty0re2wfb1g97cnj5adh4,0q7gykum4je9wsbfn3vlcxd8tr5a6p2z,0dk5sepij8v4mqhc7bfalgnuw12xo9yt,dvl6sem1bz750uq9wofhj8yx4trncpak,adb7tu6cwogz4h9fep1yli83qmk0jn2r,vu5h3njq0d9gzax8fmw27c16oetk4rlb,lktxpnzfe2y6wq7mdrh54iva9sc138j0,gxi82mbvjan6k4t0y3hr7c1qozlwsf9e,r19tpdjve3w48ua75moc6fn2kygxbzhq,sy10qemwiu9vt2zcfkd7jprag6n48hol,gr6lmxiu9t5zdnew3fcqh7j8b1yv0ksa,uyths1i80jpva5cw2lx3g9do7kf6zer4,jd71hxp4lz5i8sqoafg2bemw3crt96u0,y2q5sm1b9zgpw8kfvr6x7d0ctu4oenja,4giovl90y3uw1zxmserkjpd7825ach6q,7hjb23qr9pvdiua6n4ksox5lgfyce0z1,oh8nq2r1c3i5e06pfuldgkvbwtxm74js,tuwx26hfmbk5cqj98l71a0g4iypo3svn,im58b40sntowrpleaf6zkv3721yqj9cx,6hkv5g3syjzfe4nqtx201wr89bi7olac,dakt80e642qmnysgj5zol39ui7vw1cxp,z1uv74o5i0wljkhxbysdpmrtf9g6caq3,rpo0cains46yq2xhl9t7fw83kem5z1dj,an2v8fedghwtu5qk6zylbo7r9xi1p430,cgjylvio6aqe102x5pbszmk93t7dunwh,r2jk597hczuvm0i31p6qetaos8wyxlbf,x3omepgztdi4bnv5hkac687luq9yj02w,e8prgm2ydlcf43wx967nu15tokzbj0ai,19y2dmoqfbnhwla3xi4puzt6sk0rge58,n9kivlq8g1fhcy3z702drxj5wampeu64,w280iygjnf37k5mx9raqcez6td1sh4lv,nglfdxsq71r5vywi038m4ja2hb96zkoc,7cjzouim49arv80nxg5wk1pbsdeyqhlt,aenj1c7vxp4rg2y0zqhisf983mwd56tk,m4uwt20ckanefpv5qi8s13d7jrhzlx6g,841b0if9zhkwd5sj7pmrl6oc2veguaqx,cupf2v1az7qs6jor0gdntbml58x3w9hi,mc06jkoui7y3wfxltp1r528ezvagnbq4,txrsu80gizpd2hwcm153enbk49olavqj,3z6s0omynlbiu4haf7dwtp2jrq1xgv8c,nmok3db0syl7capz1qft9vrix856wgj2,hpztlc75rnsg2k3oi0x4am1ebqyf8udv,w2qhknsof4b39p78mguzyle0c5iaxjvd,cd4equkz93frpg6ny8tol70bwmvia521,3saz2pcvq7wxhytl1oe5bf9ikrj6nd4m,8ult9gkb42c3s6vjyx7nwz1hfoapi5em,s49gr6uf1oxbi7hkpez8dm30yjnlcvat,1p9ej8al2fr5dwn0z6htym4oiv7sqcxg,6v8l1m2fjpgz9nbeais4wr70todcyh3u,zwpnvjo31xhb5ur79gkm80asfd62lcet,uxdjowni1lb58tfacerpy7m0s6h39vgk,jzakuc6o5vf7yrbxgsptlnh419e032id,osj3r01qdy45k8h27ui6tbaznglexfcm,np48b5g7cmjxa62l31uzrovefhdwisky,jz2s0v9wfy6m7pho8gixut5b3dlk4e1n,iw94f7z80ahsoj5ympnld1g2vxctbuk3,aczv9tb2e35mj0o8xidh4yng7rp6swfk";
    return [tokenString componentsSeparatedByString:@","];
}


@end
