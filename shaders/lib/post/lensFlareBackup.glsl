float fovmult = gbufferProjection[1][1] / 1.37373871;

float genLens(vec2 lightPos, float size, float dist,float rough){
	return pow(clamp(max(1.0-length((texcoord.xy+(lightPos.xy*dist-0.5))*vec2(aspectRatio,1.0)/(size*fovmult)),0.0),0.0,1.0/rough)*rough,4.1);
}

float genMultLens(vec2 lightPos, float size, float dista, float distb){
	return genLens(lightPos,size,dista,2)*genLens(lightPos,size,distb,2);
}

float genPointLens(vec2 lightPos, float size, float dist, float sstr){
	return genLens(lightPos,size,dist,1.5)+genLens(lightPos,size*4.0,dist,1)*sstr;
}

float distratio(vec2 pos, vec2 pos2, float ratio) {
	float xvect = pos.x*ratio-pos2.x*ratio;
	float yvect = pos.y-pos2.y;
	return sqrt(xvect*xvect + yvect*yvect);
}

float circleDist (vec2 lightPos, float dist, float size) {
	vec2 pos = lightPos.xy*dist+0.5;
	return pow(min(distratio(pos.xy, texcoord.xy, aspectRatio),size)/size,10.);
}

float genRingLens(vec2 lightPos, float size, float dista, float distb){
	float lensFlare1 = max(pow(max(1.0 - circleDist(lightPos,-dista, size*fovmult),0.1),5.0)-0.1,0.0);
	float lensFlare2 = max(pow(max(1.0 - circleDist(lightPos,-distb, size*fovmult),0.1),5.0)-0.1,0.0);
	
	float lensFlare = pow(clamp(lensFlare2 - lensFlare1, 0.0, 1.0),1.4);
	return lensFlare;
}

float genAnaLens(vec2 lightPos){
	return pow(max(1.4-length(pow(abs(texcoord.xy-lightPos.xy-0.5),vec2(0.5,0.8))*vec2(aspectRatio*0.1,2.0))*4.0/fovmult,0.0),1.6);
}

vec3 getColor(vec3 color, float truepos){
	return mix(color,length(color/3)*light_n*0.25,truepos*0.49+0.49)*mix(sunVisibility,moonVisibility,truepos*0.5+0.5);
}

float getLensVisibilityA(vec2 lightPos){
	float str = length(lightPos*vec2(aspectRatio,1.0));
	return (pow(clamp(str*8.0,0.0,1.0),2.0)-clamp(str*3.0-1.5,0.0,1.0));
}

float getLensVisibilityB(vec2 lightPos){
	float str = length(lightPos*vec2(aspectRatio,1.0));
	return (1.0-clamp(str*3.0-1.5,0.0,1.0));
}

vec3 genLensFlare(vec2 lightPos,float truepos,float visiblesun){
	vec3 final = vec3(0.0);
	float visibilitya = getLensVisibilityA(lightPos);
	float visibilityb = getLensVisibilityB(lightPos);
	if (visibilityb > 0.001){
		vec3 lensFlareA = genLens(lightPos,0.3,-0.45,1)*getColor(vec3(2.2, 1.2, 0.1),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,0.10,1)*getColor(vec3(2.2, 0.4, 0.1),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,0.30,1)*getColor(vec3(2.2, 0.1, 0.05),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,0.50,1)*getColor(vec3(2.2, 0.4, 2.5),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,0.70,1)*getColor(vec3(1.8, 0.4, 2.5),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,0.1,1)*getColor(vec3(0.1, 0.2, 2.5),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,-1.1,1)*getColor(vec3(0.2, 0.3, 3.6),truepos)*0.30;
			 lensFlareA+= genLens(lightPos,0.3,-1.29,1)*getColor(vec3(1.2, 1.3, 4.6),truepos)*0.30;
			 
		vec3 lensFlareB = genMultLens(lightPos,0.08,-0.30,-0.39)*getColor(vec3(2.5, 1.2, 0.1),truepos)*0.30;
			 lensFlareB+= genMultLens(lightPos,0.08,-0.20,-0.31)*getColor(vec3(2.5, 0.5, 0.05),truepos)*0.30;
			 lensFlareB+= genMultLens(lightPos,0.12,0.06,0.19)*getColor(vec3(2.5, 0.1, 0.05),truepos)*0.30;
			 lensFlareB+= genMultLens(lightPos,0.12,0.15,0.28)*getColor(vec3(1.8, 0.1, 1.2),truepos)*0.35;
			 lensFlareB+= genMultLens(lightPos,0.12,0.5,0.37)*getColor(vec3(1.0, 0.1, 2.5),truepos)*0.30;
			 		 
			 
		vec3 lensFlareC = genPointLens(lightPos,0.03,-0.55,0.5)*getColor(vec3(2.5, 1.6, 0.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.02,-0.4,0.5)*getColor(vec3(2.5, 1.0, 0.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.04,0.425,0.5)*getColor(vec3(2.5, 0.6, 0.6),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.04,-0.1,0.5)*getColor(vec3(0.7, 1.1, 3.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.04,0.1,0.5)*getColor(vec3(1.7, 2.1, 6.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.02,0.6,0.5)*getColor(vec3(0.2, 0.6, 2.5),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,0.675,0.25)*getColor(vec3(0.7, 1.1, 3.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,0.03,0.25)*getColor(vec3(0.9, 1.2, 5.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,-1.15,0.25)*getColor(vec3(0.9, 1.2, 5.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,-1.27,0.25)*getColor(vec3(0.9, 1.6, 5.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,-0.15,0.25)*getColor(vec3(0.9, 1.2, 5.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,-0.27,0.25)*getColor(vec3(0.9, 1.6, 5.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,-0.50,0.25)*getColor(vec3(0.9, 1.2, 5.0),truepos)*0.30;
			 lensFlareC+= genPointLens(lightPos,0.03,-0.67,0.25)*getColor(vec3(0.9, 1.6, 5.0),truepos)*0.30;
			  
		vec3 lensFlareD = genRingLens(lightPos,0.42,0.50,0.56)*getColor(vec3(0.1, 0.35, 2.5),truepos);
		     lensFlareD+= genRingLens(lightPos,0.62,0.50,0.56)*getColor(vec3(0.1, 0.35, 2.5),truepos)*2.5;
	
			 
		vec3 lensFlareE = genAnaLens(lightPos)*getColor(vec3(0.3,0.7,1.0),truepos);

		final = (((lensFlareA+lensFlareB)+(lensFlareC+lensFlareD))*visibilitya+lensFlareE*visibilityb)*pow(visiblesun,2.0)*(1.0-rainStrength);
	}
	
	
	return final;
}