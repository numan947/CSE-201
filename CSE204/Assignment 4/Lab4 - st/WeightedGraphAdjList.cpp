#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
#define debug(x) printf("PING AT POINT %d\n",x)
#define NULL_VALUE -999999
#define refINFINITY 999999
#define WHITE 1
#define GREY 2
#define BLACK 3
using namespace std;

class Queue
{
    int queueInitSize ;
    int queueMaxSize;
    int * data;
    int length;
    int front;
    int rear;
public:
    Queue();
    ~Queue();
    void enqueue(int item); //insert item in the queue
    int dequeue(); //returns the item according to FIFO
    bool empty(); //return true if Queue is empty
};

Queue::Queue()
{
    queueInitSize = 2 ;
    queueMaxSize = queueInitSize;
    data = new int[queueMaxSize] ; //allocate initial memory
    length = 0 ;
    front = 0;
    rear = 0;
}


void Queue::enqueue(int item)
{
	if (length == queueMaxSize)
	{
		int * tempData ;
		//allocate new memory space for tempList
		queueMaxSize = 2 * queueMaxSize ;
		tempData = new int[queueMaxSize] ;
		int i, j;
		j = 0;
		for( i = rear; i < length ; i++ )
		{
			tempData[j++] = data[i] ; //copy items from rear
		}
		for( i = 0; i < rear ; i++ )
		{
			tempData[j++] = data[i] ; //copy items before rear
		}
		rear = 0 ;
		front = length ;
		delete[] data ; //free the memory allocated before
		data = tempData ; //make list to point to new memory
	}

	data[front] = item ; //store new item
	front = (front + 1) % queueMaxSize ;
	length++ ;
}


bool Queue::empty()
{
	if(length == 0) return true ;
	else return false ;
}


int Queue::dequeue()
{
	if(length == 0) return NULL_VALUE ;
	int item = data[rear] ;
	rear = (rear + 1) % queueMaxSize ;
	length-- ;
	return item ;
}


Queue::~Queue()
{
    if(data) delete[] data; //deallocate memory
    data = 0; //set to NULL
}

//****************Queue class ends here************************

//****************Dynamic ArrayList class based************************
class ArrayList
{
	int * list;
	int length ;
	int listMaxSize ;
	int listInitSize ;
public:
	ArrayList() ;
	~ArrayList() ;
	int searchItem(int item) ;
    void insertItem(int item) ;
	void removeItem(int item) ;
	void removeItemAt(int position);
	int getItem(int position) ;
	int getLength();
	bool empty();
	void printList();
} ;


ArrayList::ArrayList()
{
	listInitSize = 2 ;
	listMaxSize = listInitSize ;
	list = new int[listMaxSize] ;
	length = 0 ;
}

void ArrayList::insertItem(int newitem)
{
	int * tempList ;
	if (length == listMaxSize)
	{
		//allocate new memory space for tempList
		listMaxSize = 2 * listMaxSize ;
		tempList = new int[listMaxSize] ;
		int i;
        for( i = 0; i < length ; i++ )
        {
            tempList[i] = list[i] ; //copy all items from list to tempList
        }
        delete[] list ; //free the memory allocated before
        list = tempList ; //make list to point to new memory
	};

	list[length] = newitem ; //store new item
	length++ ;
}

int ArrayList::searchItem(int item)
{
	int i = 0;
	for (i = 0; i < length; i++)
	{
		if( list[i] == item ) return i;
	}
	return NULL_VALUE;
}

void ArrayList::removeItemAt(int position) //do not preserve order of items
{
	if ( position < 0 || position >= length ) return ; //nothing to remove
	list[position] = list[length-1] ;
	length-- ;
}


void ArrayList::removeItem(int item)
{
	int position;
	position = searchItem(item) ;
	if ( position == NULL_VALUE ) return ; //nothing to remove
	removeItemAt(position) ;
}


int ArrayList::getItem(int position)
{
	if(position < 0 || position >= length) return NULL_VALUE ;
	return list[position] ;
}

int ArrayList::getLength()
{
	return length ;
}

bool ArrayList::empty()
{
    if(length==0)return true;
    else return false;
}

void ArrayList::printList()
{
    int i;
    for(i=0;i<length;i++)
        printf("%d ", list[i]);
    printf("Current size: %d, current length: %d\n", listMaxSize, length);
}

ArrayList::~ArrayList()
{
    if(list) delete [] list;
    list = 0 ;
}

//******************ArrayList class ends here*************************

//******************Graph class starts here**************************
class Graph
{
	int nVertices, nEdges ;
	bool directed ;
	ArrayList  * adjList ;
	ArrayList  * weightList;
    int *color,*parent,*dist;
	//define other variables required for bfs such as color, parent, and dist
	//you must use pointers and dynamic allocation

public:
	Graph(bool dir = false);
	~Graph();
	void setnVertices(int n);
	void addEdge(int u, int v,int w);
	void removeEdge(int u, int v);
	bool isEdge(int u, int v);
    int getDegree(int u);
    void printAdjVertices(int u);
    bool hasCommonAdjacent(int u, int v);
    int getDist(int u, int v);
    void printGraph();
	void bfs(int source); //will run bfs in the graph
	void dfs(int source); //will run dfs in the graph
};


Graph::Graph(bool dir)
{
	nVertices = 0 ;
	nEdges = 0 ;
	adjList = 0 ;
	parent=0;
	color=0;
	dist=0;
    weightList=0;
	directed = dir ; //set direction of the graph
	//define other variables to be initialized
}

void Graph::setnVertices(int n)
{
	this->nVertices = n ;
	if(adjList!=0) delete[] adjList ; //delete previous list
	if(parent!=0)delete[] parent;
	if(color!=0)delete[] color;
	if(dist!=0)delete[] dist;
	if(weightList!=0)delete[] weightList;
	adjList = new ArrayList[nVertices] ;
	weightList=new ArrayList[nVertices];
	parent=new int[nVertices];
	color=new int[nVertices];
	dist=new int[nVertices];
}

void Graph::addEdge(int u, int v,int w)
{
    if(u<0 || v<0 || u>=nVertices || v>=nVertices) return; //vertex out of range
    this->nEdges++ ;
	adjList[u].insertItem(v) ;
	weightList[u].insertItem(w);
	if(!directed){
        adjList[v].insertItem(u) ;
        weightList[v].insertItem(w);
	}
}

void Graph::removeEdge(int u, int v)
{
    //write this function
    int pos=adjList[u].searchItem(v);
    adjList[u].removeItem(v);
    weightList[u].removeItemAt(pos);
    if(!directed){
        int pos=adjList[v].searchItem(u);
        adjList[v].removeItem(u);
        weightList[v].removeItemAt(pos);
    }
}

bool Graph::isEdge(int u, int v)
{
    //returns true if (u,v) is an edge, otherwise should return false
    if(directed){
        if(adjList[u].searchItem(v)!=NULL_VALUE)return true;
        return false;
    }
    else{
        if(adjList[u].searchItem(v)!=NULL_VALUE&&adjList[v].searchItem(u)!=NULL_VALUE)return true;
        return false;
    }
}

int Graph::getDegree(int u)
{
    //returns the degree of vertex u
    return adjList[u].getLength();

}

void Graph::printAdjVertices(int u)
{
    //prints all adjacent vertices of a vertex u
    printf("Adjacent Nodes of %2d:",u);
    for(int i=0;i<adjList[u].getLength();i++){
        printf(" %d",adjList[u].getItem(i));
    }
    printf("\n");
    printf("weight of nodes     :");
    for(int i=0;i<weightList[u].getLength();i++){
        printf(" %d",weightList[u].getItem(i));
    }
    printf("\n");
}

bool Graph::hasCommonAdjacent(int u, int v)
{
    //returns true if vertices u and v have common adjacent vertices
    for(int i=0;i<adjList[u].getLength();i++){
        int vertice=adjList[u].getItem(i);
        if(adjList[v].searchItem(vertice)!=NULL_VALUE)return true;
    }
    return false;
}



void Graph::bfs(int source)
{
    //complete this function
    //initialize BFS variables

    for(int i=0; i<nVertices; i++)
    {
        color[i] = WHITE ;
        parent[i] = -1 ;
        dist[i] = refINFINITY ;
    }
    Queue q ;
    color[source] = GREY;
    dist[source] = 0 ;
    q.enqueue(source) ;

    while( !q.empty() )
    {
        //complete this part
        int u=q.dequeue();

        for(int i=0;i<adjList[u].getLength();i++){
            int v=adjList[u].getItem(i);
            if(color[v]==WHITE){
                dist[v]=1+dist[u];
                parent[v]=u;
                color[v]=GREY;
                q.enqueue(v);
            }
        }
        color[u]=BLACK;
    }
}

int Graph::getDist(int u, int v)
{
    //returns the shortest path distance from u to v
    //must call bfs using u as the source vertex, then use distance array to find the distance
    bfs(u);
    if(dist[v]!=refINFINITY)return dist[v];
    return refINFINITY ;
}

void Graph::printGraph()
{
    printf("\nNumber of vertices: %d, Number of edges: %d\n", nVertices, nEdges);
    for(int i=0;i<nVertices;i++)
    {
        printf("node %d:    ", i);
        for(int j=0; j<adjList[i].getLength();j++)
        {
            printf(" %3d", adjList[i].getItem(j));
        }
        printf("\n");
        printf("weight:    ");
        for(int j=0;j<weightList[i].getLength();j++){
            printf(" %3d",weightList[i].getItem(j));
        }
        printf("\n");
    }
}

Graph::~Graph()///NEED SOME CHECKING :/
{
    //write your destructor here
    delete[] parent;
    delete[] color;
    delete[] dist;
    parent=0;color=0;dist=0;
    for(int i=0;i<nVertices;i++){
        adjList[i].~ArrayList();
    }
    for(int i=0;i<nVertices;i++){
        weightList[i].~ArrayList();
    }
    delete[] weightList;
    delete[] adjList;
}


//**********************Graph class ends here******************************


//******main function to test your code*************************
int main(void)
{
    int n;
    Graph g;
    printf("Enter number of vertices: ");
    scanf("%d", &n);
    g.setnVertices(n);

    while(1)
    {
        printf("1. Add edge. 2.Delete edge 3. getDegree 4. printAdjacent Vertices\n");
        printf("5. Print Graph  6.hasCommonAdjacent 7.bfs with source 8.getDist of two nodes 9.break\n");

        int ch;
        scanf("%d",&ch);
        if(ch==1)
        {
            int u, v,w;
            scanf("%d%d%d", &u, &v, &w);
            g.addEdge(u, v, w);
        }
        else if(ch==2)
        {
            int u,v;
            cin>>u>>v;
            g.removeEdge(u,v);
        }
        else if(ch==3)
        {
            int u;
            cin>>u;
            cout<<g.getDegree(u)<<endl;
        }
        else if(ch==4){
            int u;
            cin>>u;
            g.printAdjVertices(u);
        }
        else if(ch==5)
        {
            g.printGraph();
        }
        else if(ch==6)
        {
            int u,v;
            cin>>u>>v;
            if(g.hasCommonAdjacent(u,v))cout<<"YES"<<endl;
            else cout<<"NO"<<endl;
        }
        else if(ch==7){
            int src;
            cin>>src;
            g.bfs(src);
        }

        else if(ch==8){
            int u,v;
            cin>>u>>v;
            int dist=g.getDist(u,v);
            if(dist!=refINFINITY)cout<<dist<<endl;
            else cout<<"NO PATH FROM "<<u<<" TO "<<v<<endl;
        }
        else if(ch==9){
            break;
        }
    }
}
